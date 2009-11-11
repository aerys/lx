<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX Google Services
    Ready to use Google Services such as Maps and Analytics. In order to use Google Maps.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.html="http://lx.aerys.in/html"
		xmlns:lx.google.analytics="http://lx.aerys.in/google/analytics"
		xmlns:lx.google.maps="http://lx.aerys.in/google/maps"
		id="LX Google Services">

  <!--
      @template lx.google.analytics:tracker
      Insert the Google Analytics Javascript tracking code.
    -->
  <xsl:template match="lx.google.analytics:tracker">
    <!-- @param tracker code (i.e. UA-XXXXXXX-X) -->
    <xsl:param name="code">
      <xsl:apply-templates select="@code" mode="lx:value-of"/>
    </xsl:param>

    <xsl:variable name="script">
      <xsl:text>new GoogleAnalytics('</xsl:text>
      <xsl:value-of select="$code"/>
      <xsl:text>').trackPageView();</xsl:text>
    </xsl:variable>

    <!-- Function.js -->
    <xsl:call-template name="lx.html:javascript-class">
      <xsl:with-param name="name" select="'Function'"/>
    </xsl:call-template>

    <!-- GoogleAnalytics.js -->
    <xsl:call-template name="lx.html:javascript-class">
      <xsl:with-param name="name" select="'GoogleAnalytics'"/>
    </xsl:call-template>

    <xsl:call-template name="lx.html:javascript">
      <xsl:with-param name="script" select="$script"/>
    </xsl:call-template>
  </xsl:template>

  <!--
      @template lx.google.maps:map
      Insert a map image using the Google Maps 'staticmaps' API
      (see http://code.google.com/apis/maps/documentation/staticmaps/).
    -->
  <xsl:template match="lx.google.maps:map"
		name="lx.google.maps:map">
    <!-- @param Google Maps API key -->
    <xsl:param name="api_key">
      <xsl:apply-templates select="@api-key" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param latitude of the center of the map -->
    <xsl:param name="latitude">
      <xsl:apply-templates select="@latitude" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param longitude of the center of the map -->
    <xsl:param name="longitude">
      <xsl:apply-templates select="@longitude" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param width (in pixels) of the map [0 - 640] -->
    <xsl:param name="width">
      <xsl:apply-templates select="@width" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param height (in pixels) of the map [0 - 640] -->
    <xsl:param name="height">
      <xsl:apply-templates select="@height" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param zoom level [0 - 19] -->
    <xsl:param name="zoom">
      <xsl:apply-templates select="@zoom" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param a list of markers (see lx:google.maps:marker) -->
    <xsl:param name="markers" select="lx.google.maps:marker"/>

    <xsl:variable name="pic_width">
      <xsl:choose>
	<xsl:when test="$width > 640">
	  <xsl:text>640</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$width"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="pic_height">
      <xsl:choose>
	<xsl:when test="$height > 640">
	  <xsl:text>640</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$height"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="img">
      <xsl:attribute name="src">
	<xsl:text>http://maps.google.com/staticmap?key=</xsl:text>
	<xsl:value-of select="$api_key"/>
	<xsl:text>&amp;center=</xsl:text>
	<xsl:value-of select="concat($latitude, ',', $longitude)"/>
	<xsl:text>&amp;size=</xsl:text>
	<xsl:value-of select="concat($pic_width, 'x', $pic_height)"/>
	<xsl:text>&amp;zoom=</xsl:text>
	<xsl:value-of select="$zoom"/>
	<xsl:text>&amp;markers=</xsl:text>

	<!-- markers -->
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="collection" select="$markers"/>
	  <xsl:with-param name="delimiter" select="'|'"/>
	</xsl:call-template>

	<!-- paths -->
	<xsl:if test="lx.google.maps:path">
	  <xsl:text>&amp;</xsl:text>
	  <xsl:apply-templates select="lx.google.maps:path"/>
	</xsl:if>

	<xsl:text>&amp;format=png</xsl:text>
	<xsl:text>&amp;sensor=false</xsl:text>

      </xsl:attribute>

      <xsl:attribute name="width">
	<xsl:value-of select="$width"/>
      </xsl:attribute>

      <xsl:attribute name="height">
	<xsl:value-of select="$height"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <!--
      @template lx.google.maps:marker
      A Google Maps marker.
    -->
  <xsl:template match="lx.google.maps:marker"
		name="lx.google.maps:marker">
    <!-- @param latitude of the marker -->
    <xsl:param name="latitude">
      <xsl:apply-templates select="@latitude" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param longitude of the marker -->
    <xsl:param name="longitude">
      <xsl:apply-templates select="@longitude" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param size the marker -->
    <xsl:param name="size">
      <xsl:apply-templates select="@size" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param color the marker -->
    <xsl:param name="color">
      <xsl:apply-templates select="@color" mode="lx:value-of"/>
    </xsl:param>

    <xsl:value-of select="concat($latitude, ',', $longitude, ',', $size, $color)"/>
  </xsl:template>

  <!--
      @template lx.google.maps:path
      A Google Maps path.
    -->
  <xsl:template match="lx.google.maps:path">
    <!-- @param weight of the path -->
    <xsl:param name="weight">
      <xsl:apply-templates select="@weight" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param color of the path -->
    <xsl:param name="color">
      <xsl:apply-templates select="@color" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param fill-color of the path -->
    <xsl:param name="fill-color">
      <xsl:apply-templates select="@fill-color" mode="lx:value-of"/>
    </xsl:param>

    <xsl:text>path=</xsl:text>
    <xsl:if test="$color != ''">
      <xsl:text>color:</xsl:text>
      <xsl:value-of select="$color"/>
      <xsl:text>|</xsl:text>
    </xsl:if>
    <xsl:if test="$weight != ''">
      <xsl:text>weight:</xsl:text>
      <xsl:value-of select="$weight"/>
      <xsl:text>|</xsl:text>
    </xsl:if>

    <xsl:call-template name="lx:for-each">
      <xsl:with-param name="collection" select="lx.google.maps:waypoint"/>
      <xsl:with-param name="delimiter" select="'|'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
      @template lx.google.maps:waypoint
      A Google Maps waypoint.
    -->
  <xsl:template match="lx.google.maps:waypoint">
    <!-- @param latitude of the waypoint -->
    <xsl:param name="latitude">
      <xsl:apply-templates select="@latitude" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param longitude of the waypoint -->
    <xsl:param name="longitude">
      <xsl:apply-templates select="@longitude" mode="lx:value-of"/>
    </xsl:param>
    <xsl:value-of select="concat($latitude, ',', $longitude)"/>
  </xsl:template>

</xsl:stylesheet>

