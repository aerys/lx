<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
                version="1.0">

  <xsl:variable name="LX_PREFIX" select="'lx'"/>

  <xsl:variable name="LX_TABLE">
    <xsl:value-of select="concat($LX_PREFIX, /lx:model/@name)"/>
  </xsl:variable>

  <xsl:template match="lx:select">
    <xsl:text><![CDATA[SELECT * FROM ]]></xsl:text>
    <!-- TABLE -->
    <xsl:value-of select="$LX_TABLE"/>
    <!-- WHERE -->
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin" select="' WHERE '"/>
      <xsl:with-param name="collection" select="lx:condition"/>
      <xsl:with-param name="delimiter" select="' AND '"/>
    </xsl:call-template>
    <!-- SORT -->
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin" select="' ORDER BY '"/>
      <xsl:with-param name="collection" select="lx:sort"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <!-- LIMIT -->
    <xsl:if test="@limit">
      <xsl:text> LIMIT </xsl:text>
      <xsl:if test="@offset">
	<xsl:value-of select="@offset"/>,
      </xsl:if>
      <xsl:value-of select="@limit"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:delete">
    <xsl:text>DELETE FROM </xsl:text>
    <xsl:value-of select="$LX_TABLE"/>
    <!-- WHERE -->
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin" select="' WHERE '"/>
      <xsl:with-param name="collection" select="lx:condition"/>
      <xsl:with-param name="delimiter" select="' AND '"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="lx:update">
    <xsl:text>UPDATE ></xsl:text>
    <xsl:value-of select="$LX_TABLE"/>
    <!-- SET -->
    <xsl:text> SET </xsl:text>
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="collection" select="lx:value"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <!-- WHERE -->
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin" select="' WHERE '"/>
      <xsl:with-param name="collection" select="lx:condition"/>
      <xsl:with-param name="delimiter" select="' AND '"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="lx:value">
    <xsl:value-of select="concat(@property, '=:', @property)"/>
  </xsl:template>

  <xsl:template match="lx:condition">
    <xsl:variable name="property" select="@property"/>
    <xsl:variable name="value" select="concat(':', $property)"/>
    <xsl:variable name="type" select="//lx:property[@name = $property]/@type"/>
    <xsl:variable name="operator">
      <xsl:choose>
	<xsl:when test="$type = 'string' and @operator = '='">
	  <xsl:text>LIKE</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@operator"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($property, $operator, $value)"/>
  </xsl:template>

  <xsl:template match="lx:insert">
    <xsl:text>INSERT INTO </xsl:text>
    <xsl:value-of select="$LX_TABLE"/>
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin" select="' ('"/>
      <xsl:with-param name="collection" select="lx:value/@property"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
    <xsl:text> VALUES </xsl:text>
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin" select="'(:'"/>
      <xsl:with-param name="collection" select="lx:value/@property"/>
      <xsl:with-param name="delimiter" select="', :'"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="lx:sort">
    <xsl:value-of select="@property"/>
    <xsl:if test="@desc">
      <xsl:text> DESC</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
