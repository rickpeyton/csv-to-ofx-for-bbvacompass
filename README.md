# CSV to OFX for BBVA Compass

In 2014 BBVA Compass Bank removed the option for customers to download a QFX,
OFX or QIF file containing their most recent transactions.

As a loyal YNAB user ([You Need a Budget](http://www.youneedabudget.com)) this
is extremely inconvenient. YNAB only allows importing transactions via files,
they do not offer direct connection to banking services.

This Ruby script will allow you to pass in a single CSV file as a command line
argument and it will spit out the contents of that CSV into a file labeled
bbvacompass.OFX that you can then import into YNAB.

    ruby process-bbvacompass-csv.rb sample.csv
