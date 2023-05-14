# Campaignz

## The Task

Create a rails application to show the results for TV SMS voting campaigns,
derived from the log data similar to the attached tarball.

This task should take no more than 2 hours, and probably considerably less.

#### Deliverables:

- A rails application and associated database to hold the data
- A basic web front-end to view the results which should;

  - Present a list of campaigns for which we have results.
  - When the user clicks on a campaign, present a list of the
    candidates, their scores, and the number of messages which were sent in
    but not counted

- A command-line script that will import log file data into the application.
  Any lines that are not well-formed should be discarded. The sample data
  has been compressed to be emailed to you, but your script should assume
  the data is uncompressed plain text.

- A description of your approach to this problem, including any
  significant design decisions and your reasoning in making your
  choices. (This is the most important deliverable)

#### Parsing rules;

Here is an example log line;

```txt
VOTE 1168041980 Campaign:ssss_uk_01B Validity:during Choice:Tupele CONN:MIG00VU MSISDN:00777778429999 GUID:A12F2CF1-FDD4-46D4-A582-AD58BAA05E19 Shortcode:63334
```

- All well-formed lines will have the same fields, in the same order. They
  will all begin with VOTE, then have an epoch time value, then a set
  of fields with an identifier, a colon, and the value of the field
  (e.g. 'Campaign:ssss_uk_01B')

- A campaign is an episode of voting

- 'Choice:' indicates the candidate the user is voting for. In every campaign
  there will be a limited set of candidates that can be voted for.
  If Choice is blank, it means the system could not identify the chosen
  candidate from the text of the SMS message. All such messages should
  be counted together as 'errors', irrespective of their Validity
  values. There is a limited set of values for 'Choice', each of which
  represents a candidate who can be voted for.

- Validity classifies the time when the vote arrived, relative to the time
  window when votes will count towards a candidate's score. Only votes
  with a Validity of 'during' should count towards a candidate's score.
  Other possible values of Validity are 'pre' (message was too early to be
  counted), 'post' (message was too late to be counted). 'pre' and 'post'
  messages should be counted together irrespective of the candidate chosen.

- The CONN, MSISDN, Shortcode and GUID fields are not relevant to this
  exercise.

## Approach

### Data Structure

Looking at the requirements, my approach would be to structure the data as follows;

- `Campaign` table.

  - id (PRIMARY KEY)
  - name (STRING, null `false`)
  - total votes (INTEGER. All votes cast for this campaign with `Validity:during`, default `0`)

- `Candidate` table.

  - id (PRIMARY KEY)
  - name (STRING, null `false`)

- `CampaignEpisode` table. This would be a join table (many to many between
  `campaigns` and `candidates`) with some extra helpful information.
  - id (PRIMARY KEY)
  - campaign_id (FOREIGN KEY)
  - candidate_id (FOREIGN KEY)
  - score (INTEGER. all votes collected with `Validity:during`, default `0`)
  - invalid_votes (INTEGER. all votes collected with `Validity:pre/post`, default `0`)

#### Activerecord models

My activerecord models would look something like;

```ruby
class Campaign < ActiveRecord::Base
  has_many :campaign_episodes
  has_many :candidates, through: :campaign_episodes
end

class Candidate < ActiveRecord::Base
  has_many :campaign_episodes
  has_many :campaigns, through: :campaign_episodes
end

class CampaignEpisode < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :candidate
end
```

### Building the data

> - A command-line script that will import log file data into the application.
>   Any lines that are not well-formed should be discarded. The sample data
>   has been compressed to be emailed to you, but your script should assume
>   the data is uncompressed plain text.

I decided that this can take the shape of a rake task which will receive a file
(log file) as it's argument. The purpose of this rake task would be to parse the
log file data and create the necessary records based on it.

> - The CONN, MSISDN, Shortcode and GUID fields are not relevant to this
>   exercise.

The file will consist of 'well-formed lines' will have all the information we require.
In fact, we only care about;

```text
VOTE 1168041980 Campaign:ssss_uk_01B Validity:during Choice:Tupele
```

P.S. I left the [epoch time](https://en.wikipedia.org/wiki/Unix_time) value above
just because I think it would be cool to also include a translated version of it
in the `CampaignEpisode` table - something like `CampaignEpisode#vote_arrived_at`.
Not part of the requirements so will park that for now but can be done easily.

```irb
irb(main):001:0> Time.at(1168041980)
=> 2007-01-06 01:06:20 +0100
```

#### A few things to consider before writing the rake task

- the log files can be pretty big, In fact the size of the provided votes.txt
  file is 2086843 bytes (2.01 mb). Assuming the future log files provided will get
  even bigger, the solution for parsing these log files should be efficient.
  After playing around benchmarking using a file 10x the size of the one provided
  (20596800 bytes) and the results are as follows;

```sh
Ruby Version: 3.1.2
Filesize being read: 20596800
Lines in file: 840000

                                               user       system     total      real
'using File.open(filename).each_line.map' -->  0.517936   0.126570   0.644506   (0.646688)
'using File.open(filename).read.split'    -->  0.000013   0.000009   0.000022   (0.000021)
```

I wanted to return an array of regex matched data from the file and in the above
[benchmark](https://github.com/ruby/benchmark) example I opened the `File` and
used `each_line` and `read` and `split` (newlines) to read the files line by line.
The advantage of reading a large file line by line as opposed to slurping the file
is that;

> slurping has the problem of not being scalable; You could end up trying to read
> a file bigger than memory, taking your machine to its knees, while reading
> line-by-line will never do that.

_ref: [this awesome stackoverflow post](https://stackoverflow.com/questions/12412474/what-is-the-most-performant-way-of-processing-this-large-text-file)_

With this in mind, we could go line by line and build the data as we iterate.

- Idempotency. We need to be careful not to create the same records multiple
  times and make sure that we only create a record if it does not exist and allow
  the script to be run multiple times if needs be without corrupting our data.
  This would be a good safeguard against a scenario where for one reason or
  another the script breaks halfway through and needs to be run again.

- The log file location. The requirements do not mention how the files will be
  provided for the script to run i.e. will they be stored in a remote server like
  a bucket in amazon s3 or will they be imported into the app somewhere. Since
  this is not specified in the requirements, I am going to just place them somewhere
  in the app. Maybe, `lib/assets/votes_data/`.

My approach for parsing the file would be to first build a simple data structure
(an array of hashes to begin with) using regex to quickly scan and collect the
data I need. The advantage here would be a reduction in calls to the database.
I first thought about iterating over the file line by line and getting the data
I need and creating a record like so;

```ruby
# WARNING: a bit of sudo code mixed in here

File.open('vote.txt').read.split do |line|
  campaign_name, choice, validity = line.extract_using_regex_or_something(
    :campaign_name, :choice, :validity
  )

  campaign = Campaign.find_or_create_by(name: campaign_name)
  candidate = Candidate.find_or_create_by(name: choice)
  campaign_episode = CampaignEpisode.find_or_create_by(
    campaign: campaign,
    candidate: candidate
  )

  campaign.increment(:total_votes)
  campaign_episode.increment(:total_votes)
end
```

As you can see it is not a good solution at all to do this over every line.
Considering, the `votes.txt` file provided is almost 13k lines long, that would
mean almost 13k db calls.\
😱!!

That scream emoji deserved to stand alone on a line by itself.
What if we could just quickly load the data into memory using regex?
Now consider the following;

```ruby
# WARNING: more sudo code mixed in here

giant_string = File.open('vote.txt').read

matched_data = giant_string.scan(/some-awesome-regex/)

parsed_data = SomeClassThatParsesTheMatchedData.new(matched_data)

# imagine parsed_data returns something like
[
  {
    campaign: "ssss_uk_01B",
    total_votes: 263,
    candidates: [
      { name: "Antony", total_votes: 19, validity_pre: 0, validity_post: 0, validity_during: 19 },
      { name: "Leon", total_votes: 1, validity_pre: 0, validity_post: 0, validity_during: 1 },
      { name: "Tupele", total_votes: 122, validity_pre: 0, validity_post: 0, validity_during: 122 },
      { name: "Jane", total_votes: 68, validity_pre: 0, validity_post: 0, validity_during: 68 },
      { name: "Mark", total_votes: 9, validity_pre: 0, validity_post: 0, validity_during: 9 },
      { name: "Verity", total_votes: 4, validity_pre: 0, validity_post: 0, validity_during: 4 },
      { name: "Matthew", total_votes: 10, validity_pre: 0, validity_post: 0, validity_during: 10 },
      { name: "Gemma", total_votes: 8, validity_pre: 0, validity_post: 0, validity_during: 8 },
      { name: "Hayley", total_votes: 11, validity_pre: 0, validity_post: 0, validity_during: 11 },
      { name: "Alan", total_votes: 9, validity_pre: 0, validity_post: 0, validity_during: 9 },
      { name: "Elaine", total_votes: 2, validity_pre: 0, validity_post: 0, validity_during: 2 }
    ]
  },
  {
    campaign: "Emmerdale",
    total_votes: 77,
    candidates: [
      { name: "GRAYSON", total_votes: 14, validity_pre: 0, validity_post: 0, validity_during: 14 },
      { name: "LEN", total_votes: 7, validity_pre: 0, validity_post: 0, validity_during: 7 },
      { name: "ROSEMARY", total_votes: 28, validity_pre: 0, validity_post: 0, validity_during: 28 },
      { name: "JIMMY", total_votes: 5, validity_pre: 0, validity_post: 0, validity_during: 5 },
      { name: "JAMIE", total_votes: 6, validity_pre: 0, validity_post: 0, validity_during: 6 },
      { name: "CARL", total_votes: 3, validity_pre: 0, validity_post: 0, validity_during: 3 },
      { name: "MATTHEW", total_votes: 11, validity_pre: 0, validity_post: 0, validity_during: 11 },
      { name: "TERRY", total_votes: 2, validity_pre: 0, validity_post: 0, validity_during: 2 },
      { name: "BOB", total_votes: 1, validity_pre: 0, validity_post: 0, validity_during: 1 }
    ]
  },
  {
    campaign: "ssss_uk_02A",
    total_votes: 8174,
    candidates: [
      { name: "Alan", total_votes: 1217, validity_pre: 95, validity_post: 0, validity_during: 1122 },
      { name: "Antony", total_votes: 2082, validity_pre: 78, validity_post: 0, validity_during: 2004 },
      { name: "Leon", total_votes: 689, validity_pre: 58, validity_post: 0, validity_during: 631 },
      { name: "Tupele", total_votes: 499, validity_pre: 32, validity_post: 0, validity_during: 467 },
      { name: "Jane", total_votes: 13, validity_pre: 13, validity_post: 0, validity_during: 0 },
      { name: "Verity", total_votes: 1309, validity_pre: 76, validity_post: 0, validity_during: 1233 },
      { name: "Matthew", total_votes: 330, validity_pre: 32, validity_post: 0, validity_during: 298 },
      { name: "Gemma", total_votes: 921, validity_pre: 48, validity_post: 0, validity_during: 873 },
      { name: "Mark", total_votes: 994, validity_pre: 51, validity_post: 0, validity_during: 943 },
      { name: "Hayley", total_votes: 120, validity_pre: 69, validity_post: 0, validity_during: 51 }
    ]
  },
  # and so on
]
```

In this above situation we would now just iterate over the `parsed_data` and do something like;

```ruby
parsed_data.each do |data|
  campaign = Campaign.find_or_create_by(name: data[:campaign])
  campaign.update(total_votes: data[:total_votes])

  data[:candidates].each do |candidate|
    # find_or_create_by candidate[:name]
    # then create the CampaignEpisode with appropriate data
    # etc.
    # you get the idea...
  end
end
```

Even though there would still be a few db calls to consider, there are only 5 or
6 different campaigns and there are a limited number of candidates for each of
them and if you do the maths; it is significantly less than the aforementioned
13k iterations.

## Prerequisites

Make sure you have the following installed on your system:

- Ruby `3.1.2`
- Rails `7.0.4`
- Bundler `2.3.15`
- PostgreSQL
  - Ensure you have the [pg gem](https://github.com/ged/ruby-pg) installed
    successfully before continuing (unless you want to run in docker container)
- Docker (optional)
- Docker-Compose (optional)

## Getting Started

Clone this repo

```shell
$ git clone https://github.com/genzade/campainz.git path/to/app
$ cd path/to/app
$ bin/setup
```

Run the rake task to import all the data from the provide votes.txt

```sh
$ bin/rake import_episode_data:run\[votes.txt\] --trace
```

Note: The above rake task uses the file `lib/assets/vote_data/votes.txt`, if you
want to import a different valid log file you must add it to `lib/assets/vote_data/`
directory and run the above rake command with your filename.

### Start the App

```shell
$ bin/rails s
```

If you have docker and docker-compose installed, you can run the following instead;

```shell
$ docker-compose up --build --renew-anon-volumes
```

go to `localhost:3000`

## Running Tests

```shell
$ bundle exec rspec spec
```
