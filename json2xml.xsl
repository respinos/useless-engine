<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:m="http://example.com/ns/md-corpus"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all"
                version="3.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/fn:map" priority="101">
    <m:post>
      <m:head>
        <xsl:apply-templates select="fn:string" mode="head" />
        <xsl:apply-templates select="fn:array[@key='tags']" />
      </m:head>
      <xsl:apply-templates select="fn:map[fn:string[@key='type']]" />
    </m:post>
  </xsl:template>

  <xsl:template match="fn:string" mode="head">
    <xsl:element name="m:{@key}">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fn:array[@key='tags']">
    <m:tags>
      <xsl:for-each select="fn:string">
        <m:tag>
          <xsl:value-of select="."/>
        </m:tag>
      </xsl:for-each>
    </m:tags>
  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='type'][. = 'text']]" priority="101">
    <xsl:choose>
      <xsl:when test="fn:array[@key='marks']">
        <xsl:variable name="marks" select="fn:array[@key='marks']/fn:map" />
        <xsl:apply-templates select="$marks[1]" mode="mark">
          <xsl:with-param name="marks" select="$marks[position() > 1]" />
          <xsl:with-param name="text" select="fn:string[@key='text']" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="fn:string[@key='text']"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='type'][.='list']]" priority="101">
    <xsl:variable name="preceding-sibling" select="preceding-sibling::fn:map[1]" />
    <xsl:choose>
      <xsl:when test="$preceding-sibling[fn:string[@key='type'][.='list']]"></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="break" select="following-sibling::fn:map[fn:string[@key = 'type'][. != 'list']][1]" />
        <xsl:variable name="list-items" select="self::*, following-sibling::fn:map[fn:string[@key = 'type'][. = 'list']][empty($break) or . &lt;&lt; $break]" />
        <xsl:apply-templates select="$list-items[1]" mode="build-list">
          <xsl:with-param name="list-items" select="$list-items" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="fn:map[fn:map[@key='attrs']/fn:string[@key='kind'][.='bullet']]" mode="build-list">
    <xsl:param name="list-items" />
    <m:list type="bullet">
      <xsl:for-each select="$list-items">
        <xsl:apply-templates select="." mode="list-item" />
      </xsl:for-each>
    </m:list>
  </xsl:template>

  <xsl:template match="fn:map[fn:map[@key='attrs']/fn:string[@key='kind'][.='ordered']]" mode="build-list">
    <xsl:param name="list-items" />
    <m:list type="ordered">
      <xsl:for-each select="$list-items">
        <xsl:apply-templates select="." mode="list-item" />
      </xsl:for-each>
    </m:list>
  </xsl:template>

  <xsl:template match="fn:map[fn:map[@key='attrs']/fn:string[@key='kind'][.='task']]" mode="build-list">
    <xsl:param name="list-items" />
    <m:debug>TASK LIST</m:debug>
    <m:list type="task">
      <xsl:for-each select="$list-items">
        <xsl:apply-templates select="." mode="list-item" />
      </xsl:for-each>
    </m:list>
  </xsl:template>

  <xsl:template match="fn:map" mode="list-item">
    <m:li>
      <xsl:if test="fn:map[@key='attrs']">
        <xsl:apply-templates select="fn:map[@key='attrs']/fn:boolean" mode="attr"/>
      </xsl:if>
      <xsl:apply-templates select="fn:array[@key='content']/fn:map" />
    </m:li>
  </xsl:template>


  <xsl:template match="fn:map" mode="mark">
    <xsl:param name="marks"/>
    <xsl:param name="text"/>
    <xsl:element name="m:{fn:string[@key='type']}">
      <xsl:if test="fn:map[@key='attrs']">
        <xsl:apply-templates select="fn:map[@key='attrs']/fn:string" mode="attr"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$marks[1]">
          <xsl:apply-templates select="$marks[1]" mode="mark">
            <xsl:with-param name="marks" select="$marks[position() > 1]" />
            <xsl:with-param name="text" select="$text" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fn:map[fn:string[@key='type']]">
    <xsl:element name="m:{fn:string[@key='type']}">
      <xsl:apply-templates select="fn:map[@key='attrs']/*" mode="attr" />
      <xsl:apply-templates select="fn:array[@key='content']/fn:map" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="fn:string" mode="attr">
    <xsl:attribute name="{@key}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="fn:boolean" mode="attr">
    <xsl:attribute name="{@key}">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <!-- <xsl:attribute name="type">
      <xsl:text>xs:boolean</xsl:text>
    </xsl:attribute> -->
  </xsl:template>

  <xsl:template match="fn:number" mode="attr">
    <xsl:attribute name="{@key}">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <!-- <xsl:attribute name="type">
      <xsl:text>xs:integer</xsl:text>
    </xsl:attribute> -->
  </xsl:template>

</xsl:stylesheet>