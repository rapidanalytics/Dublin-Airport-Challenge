![dublin-airport-logo](https://www.dublinairport.com/DublinAirportTheme/css/imgs/dublin_airport_logo.png?raw=true)CHALLENGE

The challenge for Dublin Airport is to predict how many passengers will need to be processed at each fifteen minute interval in the day. This figure drives roster patterns, staffing decisions, training times, maintenance and repair schedules and a series of other pieces in this key process for Dublin Airport.

Think you can solve the problem? [Register here to access the anonymized data set](https://ti.to/hackathon-conference/travel-meets-big-data/)

Currently Dublin Airport has a model that forecasts how many passengers will present at security in each fifteen minute interval per day. This is done by examining historical patterns and also using expert judgement within Dublin Airport’s operations team which has decades of experience in this area.

![security checks](http://www.futuretravelexperience.com/wp-content/uploads/2016/03/NL110316-dublin-airport.jpg?raw=true)

The challenge for participants is to see whether they can build a predictive model that outperforms the current approach in terms of more accurately predicting passenger volumes per flight and when those passengers will present at security screening at Dublin Airport.

See attached some files for the Dublin Airport challenge (hackathon):

•	[train_unhashed_examples.csv](train_unhashed_examples.csv) contains a non-hashed sample of records so that the contestants can see some real data points and get a better intuition for the dataset

•	[data_dictionary.pdf](data_dictionary.pdf) provides the description of each column in the data

•	[daa_hackathon_starter_code.py](daa_hackathon_starter_code.py) / [daa_hackathon_starter_code.r](daa_hackathon_starter_code.r) are examples in Python and R code to read in the data and generate a simple prediction to help you get started and how Dublin Airport are measuring the model error

## DETAILS

What is the model predicting:

> How many passengers for a given flight will present at security in each of the fifteen minute intervals for the four hours before the flight departs

Note that for different flights, you will be asked to predict different points in the future e.g. for one flight number, you might be asked to predict the passenger presentation profile for tomorrow. For another flight, you might be asked to predict the passenger presentation profile one week from now. For another, it may be one month from now.

Explanatory data includes:

- Flight number level data (sampled) on historical security screening presentation profiles
- Anonymised variables that give meta-data about the flight, route, destination, etc.

Additional background information is available on the [official BUILD Challenge website](http://entanon.com/build/challenge-dublin-airport-an-efficient-experience-at-security-screening/).

## Got questions?

Please use the [Issues section](https://github.com/rapidanalytics/Dublin-Airport-Challenge/issues) to engage with the organizers.
 

