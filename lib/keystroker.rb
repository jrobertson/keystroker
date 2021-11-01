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
  
  def initialize(kbml='<kbml/>', debug: false)
    
    @debug = debug
    
    @doc = if kbml then
    
      s, _ = RXFHelper.read(kbml)
            
      head, body = s.lines[0].chomp, s.lines[1..-1].join
      puts 'head:' + head.inspect if @debug
      
      case head
      when /<\?kbml\?\>/
        parse_slim(body)
      when /<\?hg0\?\>/
        parse_hg0(body)
      else
        Rexle.new(s)
      end
      
    end
    
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
  
  def parse_slim(s)    
    
    puts 'inside parse_slim' if @debug
    
    a = s.strip.lines.map do |line|

      head, rawbody = line.chomp.split(/ +/,2)
      body = rawbody ? rawbody.strip : nil
      puts 'head: ' + head.inspect if @debug

      case head.to_sym
      when :activate
        [:window, {activate: body}]
      when :enter
        [:enter, {}]
      when :sleep
        [:sleep, {duration: body}]                
      when :tab
        [:tab, {times: body}]
      when :type
        [:type, {}, body]                
      end

    end
    
    rawxml = ['kbml', {}, '', *a]

    @doc = Rexle.new(rawxml)

  end
  
  def to_au3()

    a = []

    @doc.root.each_recursive do |x|

      next unless x

      if x.name == 'type' then
        a << ''
        a << %Q{Send("%s")} % x.text
      else

        modifiers = {ctrl: '^', shift: '+', alt: '!', win: '#'}

        instruction = if modifiers[x.name.to_sym] then
          modifiers[x.name.to_sym]
        else
          "{%s}" % x.name.upcase
        end

        if x.attributes[:key] then
          instruction += '' + x.attributes[:key] + ''
        end

        a << %Q{Send("%s")} % instruction
        a << '' if x.name == 'enter'
      end

    end
    
    puts a.join("\n")      
  end
  
  def to_doc()
    @doc
  end

  def to_hg0()
    
    a = []

    @doc.root.each_recursive do |x|

      if @debug then
        puts ('x:' + x.inspect).debug
        puts ('x2: ' + x.next_sibling.inspect).debug
      end
      
      next unless x
      
      if x.name == 'type' then
        a << ' ' + x.text
      else
        instruction = x.name
        instruction += '+' + x.attributes[:key] if x.attributes[:key]
        a << ' {' + instruction + '}'
      end

    end
    
    a.join.lstrip
    
  end

  def to_kbml(options={})
    @doc.xml(options)
  end
  
  def to_vbs()
    
    a = []

    @doc.root.each_recursive do |x|

      next unless x

      if x.name == 'type' then
        a << ''
        a << %Q(WshShell.SendKeys "%s") % x.text
      else

        modifiers = {ctrl: '^', shift: '+', alt: '%'}

        instruction = if modifiers[x.name.to_sym] then
          modifiers[x.name.to_sym]
        else
          "{%s}" % x.name.upcase
        end

        if x.attributes[:key] then
          instruction += '{' + x.attributes[:key] + '}'
        end

        a << %Q(WshShell.SendKeys "%s") % instruction
        a << '' if x.name == 'enter'
      end

    end
    
    a.prepend('Set WshShell = WScript.CreateObject("WScript.Shell")' + "\n")
    puts a.join("\n")    
  end

end

