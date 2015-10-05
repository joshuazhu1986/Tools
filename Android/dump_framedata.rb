# Summary: This script is used for dumping data related to graphic frame in android devices, it utilizes "adb shell dumpsys gfxinfo" command to dump data into files in a regular freqency.

# Usage: The script accepts one argument which is process name you want to profile data.
# To start dumping, In terminal, issue "Ruby dump_framedata.rb [your process name]"
# To stop dumping, in terminal, press ctrl+c

require 'pathname'

$PROCESS_NAME=ARGV[0]
$FileName=ARGV[0]
$SlEEP_TIME=5
$MATCH_ACTIVITY=/(.+[.].+[.].+[\/])+/
$MATCH_DATA=/(\s+\d+.\d+){3}/
$PROFILE_DATA_START="Profile data in ms:\r\n"
$PROFILE_DATA_END="View hierarchy:\r\n"
$dataTable = Hash.new


# Delete all old frame data files
def deleteRawDataFiles()
    currentPath = File.dirname(__FILE__)
    Dir.foreach(currentPath) do |x|
        begin
            if x.to_s.end_with?(".framedata.txt") then
                File.delete(x.to_s)
                puts "deleting #{x.to_s}"
            end
            rescue
            next
        end
    end
end

def deleteProfileData()
    currentPath = File.dirname(__FILE__)
    Dir.foreach(currentPath) do |x|
        begin
            if x.to_s.end_with?("profile.txt") then
                File.delete(x.to_s)
                puts "deleting #{x.to_s}"
            end
            rescue
            next
        end
    end
end


# dump framedata into files
def dumpFramedata()
    i=0
    while true
        puts "Dumping frame data into file framedata#{i}.txt"
        fork do
            exec("adb shell dumpsys gfxinfo #$PROCESS_NAME >framedata#{i}.framedata.txt")
            exit
        end
        i+=1
        sleep $SlEEP_TIME
    end
end

def extractDataInFile(fileName, dataHashTable)
    file = File.new(fileName, "r")
    gotoLineinFile(file, $PROFILE_DATA_START)
    extractDataInternal(file, dataHashTable)
end

def extractProfileData()
    currentPath = File.dirname(__FILE__)
    Dir.foreach(currentPath) do |x|
        begin
            if x.to_s.end_with?".framedata.txt" then
                extractDataInFile(x, $dataTable)
            end
        end
    end
    writeTableIntoFiles($dataTable)
end

def extractDataInternal(fileObj, dataHashTable)
    current = fileObj.gets
    while current != $PROFILE_DATA_END
        if current =~ $MATCH_ACTIVITY then
            if dataHashTable[current] == nil then
                dataHashTable[current] = Array.new
            end
            activity = current
            fileObj.gets # skip column name line
            current = fileObj.gets
            while current =~ $MATCH_DATA do
                dataHashTable[activity].push(current)
                current = fileObj.gets
            end
        end
        current = fileObj.gets
    end
end

def writeTableIntoFiles(dataHashTable)
    i=0
    dataHashTable.each do |x|
        file = File.new("data#{i}.profile.txt", "w")
        file.puts x
        i+=1
    end
end

def printHashTable(dataHashTable)
    dataHashTable.each do |x|
        puts x
        puts "\r\n"
    end
end


def gotoLineinFile(file, destLine)
    while true
        if file.gets==destLine then
            break
        end
    end
end

# using adb shell to dump profile data into files
def dumpData()
    puts "Frame data dumping starts"
    deleteRawDataFiles
    dumpFramedata 
end

# group data by activity and write them into files
def aggregateData()
    deleteProfileData
    extractProfileData
end


at_exit do
    puts "frame data dumping stopped!"
    aggregateData
end


dumpData
