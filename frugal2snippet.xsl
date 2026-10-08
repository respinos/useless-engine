<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:m="http://example.com/ns/md-corpus"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all"
                version="3.0">

  <xsl:output 
    method="xhtml" 
    html-version="5.0" 
    encoding="UTF-8" 
    indent="yes" 
    omit-xml-declaration="yes"
    suppress-indentation="xhtml:pre" />

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:param name="do-snippets" as="xs:string" select="'yes'" />
  <xsl:param name="path" as="xs:string" select="''" />

  <xsl:include href="_frugal.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/m:post">
    <xhtml:section>
      <xsl:apply-templates select="m:doc" />
    </xhtml:section>
  </xsl:template>

</xsl:stylesheet>