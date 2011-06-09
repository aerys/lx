<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.html="http://lx.aerys.in/html"
		xmlns:lx.facebook="http://lx.aerys.in/facebook"
		xmlns:fb="http://www.facebook.com/2008/fbml"
                exclude-result-prefixes="lx.facebook">

  <xsl:template match="lx.facebook:application">
    <xsl:variable name="id">
      <xsl:apply-templates select="@id" mode="lx:value-of"/>
    </xsl:variable>
    <xsl:variable name="url">
      <xsl:apply-templates select="@url" mode="lx:value-of"/>
    </xsl:variable>

    <!--<script src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php"
	    type="text/javascript">
    </script>-->

    <div id="fb-root"></div>

    <script src="{$LX_RESPONSE/@protocol}://connect.facebook.net/fr_FR/all.js"></script>

    <xsl:variable name="init_script">
      FB.init({appId: '<xsl:value-of select="$id"/>',
               status: true,
               cookie: true,
               xfbml: true});
    </xsl:variable>

    <xsl:call-template name="lx.html:javascript">
      <xsl:with-param name="script" select="normalize-space($init_script)"/>
    </xsl:call-template>

    <xsl:if test="$LX_TEMPLATE//lx.facebook:share
                  or $LX_LAYOUT//lx.facebook:share">
      <xsl:variable name="share_script">
        function lx_facebook_share(myName, myImage, myCaption, mySource, myLink)
        {
          var attachment = {
            name:    myName,
            href:    '<xsl:value-of select="$url"/>',
            caption: myCaption,
            media:[{
              type:  "image",
              src:   myImage,
              href:  '<xsl:value-of select="$url"/>'
            }]
        };

        var action_links = [{
          text: "Jouer",
          href: '<lx:value-of select="$url"/>'
        }];

        FB_RequireFeatures(["Connect"], function()
        {
          FB.ensureInit(function()
          {
            FB.Connect.streamPublish('', attachment, action_links);
          });
         });
      }
        </xsl:variable>

      <xsl:call-template name="lx.html:javascript">
        <xsl:with-param name="script" select="normalize-space($share_script)"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

  <xsl:template match="lx.facebook:share">
    <xsl:variable name="script">
      lx_facebook_share(<xsl:value-of select="concat($LX_DQUOTE, @name, $LX_DQUOTE)"/>,
                        <xsl:value-of select="concat($LX_DQUOTE, @image, $LX_DQUOTE)"/>,
                        <xsl:value-of select="concat($LX_DQUOTE, @caption, $LX_DQUOTE)"/>,
                        <xsl:value-of select="concat($LX_DQUOTE, @source, $LX_DQUOTE)"/>,
                        <xsl:value-of select="concat($LX_DQUOTE, @link, $LX_DQUOTE)"/>);
    </xsl:variable>

    <span onclick="javascript:{normalize-space($script)}">
      <xsl:apply-templates select="node()"/>
    </span>
  </xsl:template>

  <xsl:template match="lx.facebook:attachment">
    <xsl:text>{</xsl:text>
    <xsl:for-each select="@*">
      <xsl:value-of select="name()"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="."/>
    </xsl:for-each>

    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="lx.facebook:media">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates select="@type"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="@src"/>
    <xsl:if test="@href">
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="@type"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*[ancestor::lx.facebook:media]">
    <xsl:value-of select="name()"/>
    <xsl:text>:</xsl:text>
    <xsl:choose>
      <xsl:when test=". = number(.)">
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat($LX_DQUOTE, ., $LX_DQUOTE)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx.facebook:like">
    <fb:like>
      <xsl:apply-templates select="@*"/>
    </fb:like>
    <xsl:variable name="like_script">
      <xsl:text>FB.Event.subscribe('edge.create', function(href, widget) {</xsl:text>
      <xsl:apply-templates select="lx.html:javascript/text()"/>
      <xsl:text>});</xsl:text>
    </xsl:variable>
    <xsl:call-template name="lx.html:javascript">
      <xsl:with-param name="script" select="$like_script"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
