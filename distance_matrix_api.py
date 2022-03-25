#Author - Tirth Vyas
#Date - 2022/03/22

import requests
import array
import string
import time

api_key = 'YOUR_API_KEY'

#file = open("sample.csv")
file = open("full_frame_sample.csv")

line = file.read()
file.close()

out_line = ""
start_lat = ""
start_lng = ""
end_lat = ""
end_lng = ""
#print(line)

url = "https://maps.googleapis.com/maps/api/distancematrix/json?"

counter = 0

row_count = 0

distance = 0
seconds = 0

out_line = "out_line + ride_id,rideable_type,started_at,ended_at,ride_length,day_of_week,start_station_name,start_station_id,end_station_name,end_station_id,start_lat,start_lng,end_lat,end_lng,member_casual,member,casual,month,ride_length_sec,distance,ideal_time_sec"


for x in range(219, len(line)):
    if line[x] == '\n':
        if x>219:
            out_line = out_line + ',' + str(distance) + ',' + str(seconds)
        out_line = out_line + '\n'
        row_count = row_count + 1
        counter = 0
    elif line[x] == ',':
        out_line = out_line + ','
        counter = counter + 1
        if counter == 10:
            i = x + 1
            while(line[i] != ','):
                start_lat = start_lat + line[i]
                i = i + 1
            #print("start_lat = " + start_lat + '\n')
        elif counter == 11:
            i = x + 1
            while(line[i] != ','):
                start_lng = start_lng + line[i]
                i = i + 1
            #print("start_lng = " + start_lng + '\n')
        elif counter == 12:
            i = x + 1
            while(line[i] != ','):
                end_lat = end_lat + line[i]
                i = i + 1
            #print("end_lat = " + end_lat + '\n')
        elif counter == 13:
            i = x + 1
            while(line[i] != ','):
                end_lng = end_lng + line[i]
                i = i + 1
            #print("end_lng = " + end_lng + '\n')

            payload={}
            headers = {}

            url_ = url + "origins=" + start_lat + ',' + start_lng + "&destinations=" + end_lat + ',' + end_lng + "&mode=bicycling" + "&key=" + api_key

            response = requests.request("GET", url_, headers=headers, data=payload)

            distance = response.json()["rows"][0]["elements"][0]["distance"]["value"]
            seconds = response.json()["rows"][0]["elements"][0]["duration"]["value"]

            time.sleep(0.1)

            '''
            print(distance)
            print(" ")
            print(seconds)
            print('\n')
            '''
            print("Origin_lat = " + start_lat + " Origin_long = " + start_lng + " Destination_lat = " 
            + end_lat + " Destination_lng = " + end_lng + " Distance = " + str(distance) 
            + " Ideal_time = " + str(seconds))
            print("-----------Row_no " + str(row_count) + " ------------" + '\n')
            end_lng = ""
            start_lat = ""
            start_lng = ""
            end_lat = ""
    else:
        out_line = out_line + line[x]


out = open("output.csv", 'a')
out.write(out_line)
out.close()