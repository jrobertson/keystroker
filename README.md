# Introducing the Keystroker gem

## Usage

    require 'keystroker'

    s = '{tab} this is a test {enter} {ctrl+a}'
    ks = Keystroker.new
    ks.parse_hg0(s)
    puts ks.to_kbml pretty: true

Output:

<pre>
&lt;?xml version='1.0' encoding='UTF-8'?&gt;
&lt;kbml&gt;
  &lt;tab/&gt;
  &lt;type&gt;this is a test&lt;/type&gt;
  &lt;enter/&gt;
  &lt;ctrl key='a'/&gt;
&lt;/kbml&gt;
</pre>

## Resources

* keystroker https://rubygems.org/gems/keystroker

keystroker sendkeys hidg0 gem
