
class Renderer

  # Declare built-in views
  define_view(:raw, :name=>'*account link') do
    #ENGLISH
    text = '<span id="logging">'
     if logged_in?
       text += @template.link_to( "My Card: #{User.current_user.card.name}", '/me', :id=>'my-card-link')
       if System.ok?(:create_accounts)
         text += @template.link_to('Invite a Friend', '/account/invite', :id=>'invite-a-friend-link')
       end
       text += @template.link_to('Sign out', '/account/signout', :id=>'signout-link')
     else
       if Card::InvitationRequest.create_ok?
         text+= @template.link_to( 'Sign up', '/account/signup',   :id=>'signup-link' )
       end
       text += @template.link_to( 'Sign in', '/account/signin',   :id=>'signin-link' )
     end
    text + '</span>'
  end
  
  view_alias(:raw, {:name=>'*account link'}, :naked)

  define_view(:raw, :name=>'*alerts') do %{
<div id="alerts">
  <div id="notice">#{flash[:notice]} </div>
  <div id="error">#{flash[:warning]}#{flash[:error]}</div>
</div>
} end
  view_alias(:raw, {:name=>'*alerts'}, :naked)

  define_view(:raw, :name=>'*foot') do
    javascript_include_tag "/tinymce/jscripts/tiny_mce/tiny_mce.js" +
    (google_analytics or '')
  end
  view_alias(:raw, {:name=>'*foot'}, :naked)

  define_view(:raw, :name=>'*head') do
    # ------- Title -------------
    %{<link rel="shortcut icon" href="#{ System.favicon }" />} +
    if card and !card.new_record? and card.ok? :edit
      %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="/card/edit/#{ card.key }"/>}
    else; ''; end +

    if card and card.name == "*search"
      %{<link rel="alternate" type="application/rss+xml" title="RSS" href="/search/<%= params[:_keyword] %>.rss" />}
    elsif card and Card::Search === card
      %{<link rel="alternate" type="application/rss+xml" title="RSS" href="#{ @template.url_for_page( card.name, :format=>:rss )} " />}
    else; ''; end +
    
    "<title>#{params[:title]} - #{ System.site_title }</title>" +
    
    stylesheet_link_merged(:base) +
    
    if star_css_card = Card.fetch('*css', :skip_virtual => true)
      %{<link href="/*css.css?#{ star_css_card.current_revision_id }" media="screen" type="text/css" rel="stylesheet" />}
    else; ''; end +
    #{#asset_manager can do alternate media but has to be a separate call
    
    stylesheet_link_tag( 'print', :media=>'print' ) +
        # tried javascript at bottom, much breakage
    "#{javascript_include_merged(:base)}" +
    key = System.setting("*google_ajax_api_key") ?
       %{<script type="text/javascript" src="http://www.google.com/jsapi?key=<%= key %>"></script>} : ''


  end
  view_alias(:raw, {:name=>'*head'}, :naked)

  define_view(:raw, :name=>'*navbox') do
#Rails.logger.debug("Builtin *navbox")
    #ENGLISH
    %{
<form id="navbox_form" action="/search" onsubmit="return navboxOnSubmit(this)">
  <span id="navbox_background">
    <a id="navbox_image" title="Search" onClick="navboxOnSubmit($('navbox_form'))">&nbsp;</a>
    <input type="text" name="navbox" value="#{ params[:_keyword] || '' }" id="navbox_field" autocomplete="off" />
    #{ #navbox_complete_field('navbox_field')
      content_tag("div", "", :id => "navbox_field_auto_complete", :class => "auto_complete") +
      auto_complete_field('navbox_field', {
        :url =>"/card/auto_complete_for_navbox/",
        :after_update_element => "navboxAfterUpdate" }.update({}))
    }
  </span>
</form>
    }
  end
  view_alias(:raw, {:name=>'*navbox'}, :naked)

  define_view(:raw, :name=>'*now') do Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z') end
  view_alias(:raw, {:name=>'*now'}, :naked)
  define_view(:raw, :name=>'*version') do Wagn::Version.full end
  view_alias(:raw, {:name=>'*version'}, :naked)


  private
  def navbox_complete_field(fieldname, card_id='')
    content_tag("div", "", :id => "#{fieldname}_auto_complete", :class => "auto_complete") +
    auto_complete_field(fieldname, { :url =>"/card/auto_complete_for_navbox/#{card_id.to_s}",
      :after_update_element => "navboxAfterUpdate"
     }.update({}))
  end

end
