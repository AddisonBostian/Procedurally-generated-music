#build verse/chorus arrays
chords = [:c, :f, :g]
songNum = 59887
use_bpm 100

measures = 0

def makeVerse n, len, chords
  start = 2
  nextN = 2
  lastDir = 0
  r = Random.new(n)
  n = []
  c = 0
  len.times do
    notes = chord(chords[c], :major)
    c = (c + 1 )% chords.length
    numNotes = r.rand(0...2) >= 1 ? 2 : r.rand(0...2) >= 1 ? 4 : 8
    numRests = numNotes == 8 ? 0 : numNotes == 4 ? 1 : 3
    numNotes.times do
      
      n << notes[nextN]
      numRests.times do
        n<<nil
      end
      
      if nextN-start >= 12
        lastDir = 0
      elsif nextN-start <= -2
        lastDir = 1
      end
      
      cutoff = lastDir == 1 ? 40 : 60
      num = r.rand 0..100
      if num > cutoff
        nextN = nextN+1
      else
        nextN = nextN-1
        lastDir = lastDir == 1 ? 0 : 1
      end
    end
  end
  puts n
  n
end

#chords/melody
def playArr arr, time, flag
  index = 0
  arr.each do |n|
    
    use_synth :dpulse
    
    if index%4 == 0 then play( chord( n,:major),release: 2, amp: 0.25 )end
    use_synth :pluck
    play n, amp: 2, release: 2
    if flag
      use_synth :fm
      play n
    end
    sleep time
    
    index+=1
  end
end


in_thread do
  sleep 1
  verse = makeVerse songNum, 5, chords
  chorus = makeVerse songNum+10, 3, chords
  measures = verse.length/4.0 + (chorus.length/4.0 *2)
  
  cue :tick
  playArr verse, 0.5, false
  playArr chorus, 0.5, true
  playArr verse, 0.5, false
  
end

#beat
in_thread do
  sync :tick
  measures.times do
    sample :drum_cymbal_closed
    sample :drum_bass_hard, amp: 1
    sleep 0.5
    sample :drum_cymbal_closed
    sleep 0.5
    
    sample :drum_cymbal_closed
    sample :drum_snare_hard
    sleep 0.5
    sample :drum_cymbal_closed
    sleep 0.5
  end
end

