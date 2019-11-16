# ChangeLog

## WIP Version

## 1.0.0
- Fixing overall TYPOs
[Pull Request#1](https://github.com/joaomdmoura/machinery/pull/45)
[Pull Request#2](https://github.com/joaomdmoura/machinery/pull/49)
[Pull Request#3](https://github.com/joaomdmoura/machinery/pull/56)
[Pull Request#4](https://github.com/joaomdmoura/machinery/pull/65)
[Pull Request#5](https://github.com/joaomdmoura/machinery/pull/61)
- Delegate json_decoder config to phoenix - [Pull Request](https://github.com/joaomdmoura/machinery/pull/47)
- Fixing flaky tests - [Pull Request](https://github.com/joaomdmoura/machinery/pull/50)
- Remove Pheonix dependency (and dashboard feature) - [Pull Request](https://github.com/joaomdmoura/machinery/pull/55)
- Resolve Machinery GenServer Get Timeout - [Pull Request](https://github.com/joaomdmoura/machinery/pull/58)


## 0.17.0
- Allow field name customization - [Pull Request](https://github.com/joaomdmoura/machinery/pull/42)

## 0.16.1
- Bumping Ecto version - [Pull Request](https://github.com/joaomdmoura/machinery/pull/38)

## 0.16.0
- Support for custom error messages on guard functions - [Pull Request](https://github.com/joaomdmoura/machinery/pull/35)

## 0.15.0
- Adding support for transitions logging - [Pull Request](https://github.com/joaomdmoura/machinery/pull/33)

## 0.14.0
- Adding support for wildcard transitions - [Pull Request](https://github.com/joaomdmoura/machinery/pull/32)

## 0.13.0
- Adding basic auth to Machinery Dashboard - [Pull Request](https://github.com/joaomdmoura/machinery/pull/30)

## 0.12.1
- Better treating the JSON return for the Dashboard - [Pull Request](https://github.com/joaomdmoura/machinery/pull/27)

## 0.12.0
- Adding new toogle all btn and auto closing alerts - [Pull Request](https://github.com/joaomdmoura/machinery/pull/24)
- Fixing Bug to rollback state transition on the Dashboard - [Pull Request](https://github.com/joaomdmoura/machinery/pull/25)

## 0.11.0
- Adding a default config desabling the Machinery Dashboard
- Making the Machinery Dashboard bigger
- Enabling users to overwrite the desired state on Machinery Dashboard - [Pull Request](https://github.com/joaomdmoura/machinery/pull/21)
- Adding the ability to change states form Dashboard - [Pull Request](https://github.com/joaomdmoura/machinery/pull/22)

## 0.8.2
- Requiring a previous version of phoenix_html to enable older applications to use Machinery.
- Versioning compiled version of the assets to fix bug on dashboard interface.

## 0.8.0
- Adding first version of Machinery Dashboard - [Pull Request](https://github.com/joaomdmoura/machinery/pull/14)

## 0.7.0
- Improving docs
- Updating DSl to Decouple Machinery from the struct itself - [Pull Request](https://github.com/joaomdmoura/machinery/pull/10)
- Adding support for automatic persistence - [Pull Request](https://github.com/joaomdmoura/machinery/pull/11)
- Converting states from Atoms to Strings - [Pull Request](https://github.com/joaomdmoura/machinery/pull/12)

## 0.4.1
- Updating wrong docs and README - [Pull Request](https://github.com/joaomdmoura/machinery/pull/5)

## 0.4.0
- New, more functional DSL, not relying on Macros so much - [Pull Request](https://github.com/joaomdmoura/machinery/pull/1)
- Adding support for before and after callbacks - [Pull Request](https://github.com/joaomdmoura/machinery/pull/2)

## 0.2.0
- Enabling states and transitions declarations
- Adding support for guard functions