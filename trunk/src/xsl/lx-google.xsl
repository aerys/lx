<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX Google Services
    Ready to use Google Services such as Maps and Analytics. In order to use Google Maps,
    you must set the LX_GOOGLE_MAPS_KEY variable in your view file (lx-view.xsl).
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.google.analytics="http://lx.aerys.in/google/analytics"
		xmlns:lx.google.maps="http://lx.aerys.in/google/maps"
		id="LX Google Services">

  <!--
      @template lx.google.analytics:tracker
      Insert the Google Analytics Javascript tracking code.
    -->
  <xsl:template match="lx.google.analytics:tracker">
    <!-- @param tracker code (i.e. UA-XXXXXXX-X) -->
    <xsl:param name="code" select="@code"/>

    <xsl:variable name="script">
      new GoogleAnalytics('<xsl:value-of select="$code"/>').trackPageView();
    </xsl:variable>

    <!-- Function.js -->
    <xsl:call-template name="lx:javascript-class">
      <xsl:with-param name="name" select="'Function'"/>
    </xsl:call-template>

    <!-- GoogleAnalytics.js -->
    <xsl:call-template name="lx:javascript-class">
      <xsl:with-param name="name" select="'GoogleAnalytics'"/>
    </xsl:call-template>

    <xsl:call-template name="lx:javascript">
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
    <!-- @param latitude of the center of the map -->
    <xsl:param name="latitude" select="@latitude"/>
    <!-- @param longitude of the center of the map -->
    <xsl:param name="longitude" select="@longitude"/>
    <!-- @param width (in pixels) of the map [0 - 640] -->
    <xsl:param name="width" select="@width"/>
    <!-- @param height (in pixels) of the map [0 - 640] -->
    <xsl:param name="height" select="@height"/>
    <!-- @param zoom level [0 - 19] -->
    <xsl:param name="zoom" select="@zoom"/>
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
	<xsl:value-of select="concat($LX_GOOGLE_MAPS_KEY, $LX_AMP)"/>
	<xsl:text>center=</xsl:text>
	<xsl:value-of select="concat($latitude, ',', $longitude, $LX_AMP)"/>
	<xsl:text>size=</xsl:text>
	<xsl:value-of select="concat($pic_width, 'x', $pic_height, $LX_AMP)"/>
	<xsl:text>zoom=</xsl:text>
	<xsl:value-of select="concat($zoom, $LX_AMP)"/>
	<xsl:text>markers=</xsl:text>
	<xsl:call-template name="lx:foreach">
	  <xsl:with-param name="collection" select="$markers"/>
	  <xsl:with-param name="delimiter" select="'|'"/>
	</xsl:call-template>
	<xsl:text>&amp;format=png</xsl:text>
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
    <xsl:param name="latitude" select="@latitude"/>
    <!-- @param longitude of the marker -->
    <xsl:param name="longitude" select="@longitude"/>
    <!-- @param size the marker -->
    <xsl:param name="size" select="@size"/>
    <!-- @param color the marker -->
    <xsl:param name="color" select="@color"/>

    <xsl:value-of select="concat($latitude, ',', $longitude, ',', $size, $color)"/>
  </xsl:template>

</xsl:stylesheet>

