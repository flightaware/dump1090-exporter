dump1090 Exporter
=================

A Prometheus metrics exporter for the dump1090 Mode S decoder for RTLSDR
devices.

The dump1090 exporter collects statistics from a dump1090 service and
exposes them to the Prometheus.io monitoring server for aggregation and
later visualisation.

Once installed the dump1090 exporter can be easily run from the command
line as the installation script includes a console entry point.

Example usage:

    .. code-block:: console

        $ dump1090exporter \
          --url=http://192.168.1.201:8080 \
          --port=9105 \
          --latitude=-34.9285 \
          --longitude=138.6007 \
          --debug

In the example above the exporter is instructed to monitor a dump1090
instance running on a machine with the IP address 192.168.1.201 using
the default port (8080) used by dump1090 tool. The exporter exposes a
service for Prometheus to scrape on port 9105 by default but this can
be changed by specifying it with the *--port* argument.

The example above also instructs the exporter to use a specific receiver origin (lat, lon). In this case it is for Adelaide, Australia. In most
cases the dump1090 tool is not configured with the receivers position.
By providing the exporter with the receiver location it can calculate
ranges to aircraft. If the receiver position is already set within the
dump1090 tool (and accessible from the *data/receivers.json* resource)
then the exporter will use that data as the origin.

The dump1090 exporter accepts a number of command line arguments. These
can be found by using the standard command line help request:

.. code-block:: console

    $ dump1090-exporter -h

The exporter fetches aircraft data (from *data/aircraft.json*) every 10 seconds. This can be modified by specifying a new value with the *--aircraft-interval* argument.

The exporter fetches statistics data (from *data/stats.json*) every 60 seconds, as the primary metrics being exported are extracted from the
*last1min* time period. This too can be modified by specifying a new
value with the *--stats-interval* argument.

The metrics that the dump1090 exporter provides to Prometheus can be
accessed for debug and viewing using curl or a browser by fetching from
the */metrics* url. For example:

.. code-block:: console

    $ curl -s http://0.0.0.0:9001/metrics
    # HELP messages Number of Mode-S messages accepted
    # TYPE messages gauge
    messages{time_period="latest"} 190423
    # HELP recent_aircraft_observed Number of aircraft recently observed
    # TYPE recent_aircraft_observed gauge
    recent_aircraft_observed{time_period="latest"} 1
    ...


The exporter exposes generalised metrics for statistics and uses the multi
dimensional label capability of Prometheus metrics to include information
about which group the metric is part of.

To extract information for the peak signal metric that dump1090 aggregated
over the last 1 minute you would specify the time_period for that group:

.. code-block:: console

    stats_local_peak_signal{job="dump1090", time_period="last1min"}

In the stats.json data there are 5 top level keys that contain statistics for
a different time period, defined by the "start" and "end" subkeys. The top
level keys are:

- *latest* which covers the time between the end of the "last1min" period and
  the current time.
- *last1min* which covers a recent 1-minute period. This may be up to 1 minute
  out of date (i.e. "end" may be up to 1 minute old)
- *last5min* which covers a recent 5-minute period. As above, this may be up
  to 1 minute out of date.
- *last15min* which covers a recent 15-minute period. As above, this may be up
  to 1 minute out of date.
- *total* which covers the entire period from when dump1090 was started up to
  the current time.

By default only the *last1min* time period is exported.



Prometheus Configuration
------------------------

Once the dump1090 exporter is running then Prometheus can begin scraping it.
However, Prometheus first needs to be told where to fetch the metrics from.

This can be done by updating the Prometheus configuration file with a new entry under the 'scrape_configs' block, looking something like this:

.. code-block:: yaml

    scrape_configs:
      - job_name: 'dump1090'
        scrape_interval: 10s
        scrape_timeout: 5s
        static_configs:
          - targets: ['192.168.1.201:9105']
            labels:
              site: 'home'


Docker
------

The dump1090 exporter has been packaged into a Docker container, which
can simplify running it in some environments. The container is configured with an entry point that runs the dump1090 exporter with *--help* as the default arguement.

.. code-block:: console

    $ docker run -it --rm dump1090-exporter
    usage: dump1090-exporter [-h] [--url <dump1090 url>]
    ...

To run the dump1090 exporter container simply pass the standard command
line arguments to it:

.. code-block:: console

    $ docker run --rm -p 9105:9105 \
      dump1090-exporter \
      --url=http://192.168.1.201:8080 \
      --latitude=-34.9285 \
      --longitude=138.6007 \
