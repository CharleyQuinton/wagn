require File.expand_path('../../spec_helper', File.dirname(__FILE__))
include ChunkManager
include ChunkSpecHelper

describe Chunks::Link, "link chunk tests" do

  before do
    setup_user 'joe_user'
  end

  it "should test basic" do
    card = newcard('Baines', '[[Nixon]]')
    assert_equal('<a class="wanted-card" href="/Nixon">Nixon</a>', render_test_card(card) )


    lbj_link = '<a class="known-card" href="/Baines">Lyndon</a>'

    card2 = newcard('Johnson', '[Lyndon][Baines]')
    assert_equal(lbj_link, render_test_card(card2) )

    card2.content = '[[Baines|Lyndon]]'; card2.save
    assert_equal(lbj_link, render_test_card(card2) )

  end

  it "should test relative card" do
    cardA = newcard('Kennedy', '[[+Monroe]]')
    assert_equal('<a class="wanted-card" href="/Kennedy%2BMonroe">+Monroe</a>', render_test_card(cardA) )

    cardB = newcard('Clinton', '[[Lewinsky+]]')
    assert_equal('<a class="wanted-card" href="/Lewinsky%2BClinton">Lewinsky</a>', render_test_card(cardB) )
  end

  it "should test relative url" do
    card3 = newcard('recent changes', '[[/recent]]')
    assert_equal('<a class="internal-link" href="/recent">/recent</a>', render_test_card(card3) )
  end

  it "should test external" do
    card4 = newcard('google link', '[[http://google.com]]')
    assert_equal('<a class="external-link" href="http://google.com">http://google.com</a>', render_test_card(card4) )
  end

  it "should escape spaces %20 (not +)" do
    card5 = newcard('userlink', '[Marie][Marie "Mad Dog" Deatherage]')
    assert_equal('<a class="wanted-card" href="/Marie%20%22Mad%20Dog%22%20Deatherage">Marie</a>', render_test_card(card5) )
  end

  it "should external needs not escaped" do
    card6 = newcard('google link2', 'wgw&nbsp; [google][http://www.google.com] &nbsp;  <br>')
    assert_equal "wgw&nbsp; <a class=\"external-link\" href=\"http://www.google.com\">google</a> &nbsp;  <br>", render_test_card(card6)
  end

  it "should test relative link" do
    dude,job = newcard('Harvey',"[[#{SmartName.joint}business]]"), newcard('business')
    card = Card.create! :name => "#{dude.name}+#{job.name}", :content => "icepicker"
    assert_equal("<a class=\"known-card\" href=\"/Harvey+business\">#{SmartName.joint}business</a>", render_test_card(dude) )
  end

end

