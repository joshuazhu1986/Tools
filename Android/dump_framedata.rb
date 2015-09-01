# Summary: This script is used for dumping data related to graphic frame in android devices, it utilizes "adb shell dumpsys gfxinfo" command to dump data into files in a regular freqency.

# Usage: The script accepts one argument which is process name you want to profile data.
# To start dumping, In terminal, issue "Ruby dump_framedata.rb [your process name]"
# To stop dumping, in terminal, press ctrl+c

require 'pathname'

$PROCESS_NAME=ARGV[0]
$SlEEP_TIME=5


# Delete all old frame data files
def deleteTextFiles()
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



at_exit do
    puts "frame data dumping stopped!"
    # TODO, add logic to parse frame data files and aggregate profile data raws(each row contains 'Draw', 'Process', 'Execute') into one file.
    # Note, if there is activity switch, there can be more than one acivity data each command will fetch, this should be considered for data aggregation
end


puts "Frame data dumping starts"
deleteTextFiles
dumpFramedata


        

