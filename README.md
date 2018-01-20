# Bahnhofsfotos for iOS
[![Build Status](https://travis-ci.org/RailwayStations/Bahnhofsfotos.svg?branch=master)](https://travis-ci.org/RailwayStations/Bahnhofsfotos)

iOS-App for the project "Deutschlands-Bahnhoefe"

You can find the project website on [railway-stations.org](https://railway-stations.org) and the map on [deutschlands-bahnhoefe.de](http://www.deutschlands-bahnhoefe.de).


## Requirements

### CocoaPods
```
$ sudo gem install cocoapods cocoapods-acknowledgements
```
> For macOS (since El Capitan): (╯°□°）╯︵ ┻━┻
> 
>     $ sudo gem install -n /usr/local/bin cocoapods cocoapods-acknowledgements
> or use [Homebrew](https://brew.sh) to install Ruby
> 
>     $ brew install ruby
>     $ gem install cocoapods cocoapods-acknowledgements

### apollo-codegen
You will have to install the apollo-codegen command globally through [npm](https://nodejs.org/en/):
```
npm install -g apollo-codegen
```

#### (Optional) Apollo Xcode plug-in to get GraphQL syntax highlighting
1. Clone the [xcode-apollo](https://github.com/apollographql/xcode-graphql) repository to your computer.
1. Close Xcode if it is currently running.
1. Run `./setup.sh` inside the cloned directory in your terminal.

## Installation
Run `$ pod install` in the project root directory, to download and install the dependencies.

### Generate GraphQL schema
> [https://github.com/dbsystel/1BahnQL](https://github.com/dbsystel/1BahnQL):  
> You need an active authentication token to generate the schema. You can get one on [developer.deutschebahn.com](https://developer.deutschebahn.com). After creating your account you also have to subscribe to **1BahnQL** by your own.

```
apollo-codegen download-schema https://developer.deutschebahn.com/1bahnql/graphql --output schema.json --header "Authorization: Bearer <DBDeveloperAuthorizationToken>"
```
Replace the schema.json in the project folder and build the project.

## Secrets / Keys
Copy the `Secrets-sample.plist` and rename it to `Secrets.plist`. Then fill in your keys.
