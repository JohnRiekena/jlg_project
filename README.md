# JLG Project
## Summary
This is a command line ruby script that takes an input csv file and an output csv file name as parameters. 

If the person has more than one vehicle, then this script will group all vehicles together by person, and label the unique vehicle columns as repeated numbers (i.e `make 1`, `model 1`, `make 2`, `model 2`, etc).

## Usage
```ruby
ruby process.rb -i sample.csv -o output.csv
```

## Assumptions
- The first column will always be the person identifier
- Report will be already sorted by the soonest statute of limitations expiration

## Concerns
If a client has different information between records (change of name, address, phone number, etc), the output report will use the information provided from the earliest statute of limitation. 