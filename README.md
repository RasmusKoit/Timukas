# Timukas

![Header](.images/header.png)

## About

Timukas is a project created for Microsoft's Fix Hack Learn 2023 hackathon. It is a android app that helps people learn Estonian words in a fun and interactive way by playing hangman. The app is built using Flutter together with Firebase as a backend. The app also uses [SONAPI - An API for the Estonian language](https://github.com/BenediktGeiger/sonad-api) developed by [Benedikt Geiger](https://github.com/BenediktGeiger) to get some extra information about the words. For word generation I am using [Eesti Keele Instituut](https://www.eki.ee/) word `lemmad2013.txt` file.

## Running the project

```bash
git clone https://github.com/RasmusKoit/Timukas timukas
cd timukas
cp example.env .env
flutter run
```

## License

[GNU GENERAL PUBLIC LICENSE Version 3](./LICENSE)
