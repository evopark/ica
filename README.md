# ICA WinCardCore implementation

[![CircleCI](https://circleci.com/gh/evopark/ica.svg?style=svg&circle-token=3bcbc008369109e863b139fde49e6e94c3ae6ffc)](https://circleci.com/gh/evopark/ica)

This gem implements the WinCardCore API from ICA

## Surface

The gem exposes two Rack endpoints that can be mounted in the parent
application:

`ICA::API` is the Grape-based API itself. It can be mounted
either inside a parent Grape API or stand-alone.

`ICA::Admin::Engine` is a Rails engine that provides an
administrative interface. It should be mounted in the administrator-restricted
part of the host application.
