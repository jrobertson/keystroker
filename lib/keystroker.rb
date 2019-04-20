#!/usr/bin/env ruby

# file: keystroker.rb


require 'rexle'
require 'rexle-builder'


## Usage

#   
#   s = '{tab} this is a test {enter} {ctrl+a}'
#   ks = Keystroker.new
#   ks.parse_hg0(s)
#   ks.to_kbml


class Keystroker
  using ColouredText
  
  def initialize(debug: false)
    @debug = debug
  end

  def parse_hg0(s)

    xml = RexleBuilder.new

    a3 = xml.kbml do

      a = s.gsub(/\s*(?=\{)|(?<=\})\s*/,'').scan(/\{[^\}]+\}|./)\
        .chunk {|x| x.length == 1}.map {|b, x| b ? x.join : x }.each do |x|

        if x.is_a? Array then

          x.each do |token|

            token[1..-2].split(/\s*[;,]\s*/).each do |instruction|

              puts ('instruction: ' + instruction.inspect).debug if @debug

              if instruction =~ /\*\s*\d+/ then

                key, n = instruction.split('*',2)
                #n.to_i.times {keypress(key, duration: duration) }
                xml.send(key.to_sym, {repeat: n})

              else

                keys = instruction.split('+')     

                if keys.length > 1 then
                  name = keys[0..-2].join('_').to_sym
                  xml.send(name, {key: keys.last})
                else
                  xml.send(instruction.to_sym)
                end
              end              

            end
          end

        else
          xml.type x
        end
           
      end

    end

    @doc = Rexle.new(a3)

  end

  def to_hg0()
  end

  def to_kbml(options={})
    @doc.xml(options)
  end

end

