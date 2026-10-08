<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://example.com/ns/md-corpus"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

  <xsl:template match="document-node()">
    <xhtml:html lang="en">
      <xhtml:head>
        <xhtml:meta charset="UTF-8" />
        <xhtml:meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <xhtml:link rel="stylesheet" href="static/css/styles.css" />
        <xsl:apply-templates mode="head" />
      </xhtml:head>
      <xhtml:body>
        <xhtml:div class="container">
          <xhtml:main class="main">
            <xsl:apply-templates />
          </xhtml:main>
          <xhtml:footer>
            © 2026 by your humble narrator
          </xhtml:footer>
        </xhtml:div>
      </xhtml:body>
    </xhtml:html>
  </xsl:template>


</xsl:stylesheet>