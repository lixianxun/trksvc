import sys,csv,json,pjsonpath,urllib2

if len(sys.argv) < 2:
  print("usage: url, csv_file")
  sys.exit()
  
url=str(sys.argv[1])
csv_file=str(sys.argv[2])

response=urllib2.urlopen(url)
json_txt = json.loads(response.read())

f = csv.writer(open(csv_file, "wb+"))
for x in json_txt:
  f.writerow([x["x1"], x["x2"], x["x3"] ])

print("json2csv done")
              

