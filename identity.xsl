<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:m="http://example.com/ns/md-corpus"
                exclude-result-prefixes="#all"
                version="3.0">

  <!-- ==================================================================
       Identity transform for markdown-to-xslt.xpl.

       Input is one m:corpus document containing an m:document per
       Markdown file, each holding an m:meta block of parsed front matter
       followed by the rendered xhtml:html body:

         m:corpus / m:document / m:meta / m:field / m:value
                                / xhtml:html

       This copies all of it through unchanged; add template rules below
       to start doing real work.
       ================================================================== -->

  <!-- The whole identity transform, in XSLT 3.0. The built-in rule for
       elements and document nodes copies the node (with its namespaces)
       and applies templates to its attributes and children; the rule for
       attributes, text, comments and PIs copies them outright. Any rule
       you add below simply overrides it for the nodes it matches. -->
  <xsl:mode on-no-match="shallow-copy"/>

  <!-- Passed in by the pipeline's p:xslt parameters option. Declared so
       it is available if you need it; harmless if you don't. -->
  <xsl:param name="source-dir" as="xs:string?" select="()"/>

  <!-- Serialization is controlled by the p:output serialization map in
       the pipeline, which takes precedence over anything declared here. -->
  <xsl:output method="xml" indent="yes"/>

  <!-- ==================================================================
       Add rules here. A few starting points, all inert as written:

       Reach a single front matter value. m:field always exists for a key
       that was present, so test the key rather than the value:

         <xsl:variable name="title"
                       select="m:meta/m:field[@name='title']"/>

       Multi-valued fields hold m:value children instead of text, so
       string() on the field concatenates them without separators - walk
       m:value when order or separation matters:

         <xsl:value-of select="m:meta/m:field[@name='tags']/m:value"
                       separator=", "/>

       Build an index, falling back to the first heading when a document
       has no title in its front matter:

         <xsl:template match="m:corpus">
           <index>
             <xsl:for-each select="m:document">
               <entry href="{@href}">
                 <xsl:value-of select="(m:meta/m:field[@name='title'],
                                        .//xhtml:h1)[1]"/>
               </entry>
             </xsl:for-each>
           </index>
         </xsl:template>

       Drop the metadata once you have consumed it (an empty template
       deletes the node):

         <xsl:template match="m:meta"/>

       Hoist the body out of its wrapper:

         <xsl:template match="m:document">
           <xsl:apply-templates select="xhtml:html"/>
         </xsl:template>

       Everything from the Markdown is in the XHTML namespace, so match on
       xhtml:h1 and xhtml:p - a bare h1 matches nothing. And note the
       select="@*, node()" in any hand-written xsl:copy: unlike the
       built-in shallow-copy rule, xsl:copy does not process attributes
       unless you ask it to, so leaving @* out silently drops them.
       ================================================================== -->

  <!-- ==================================================================
       If you switch the pipeline to VARIANT A (no p:wrap-sequence in step
       3, with template-name="main" on p:xslt), there is no single source
       tree to walk. Use an entry point like this instead, and drop the
       m:corpus rules above:

         <xsl:template name="main">
           <corpus>
             <xsl:apply-templates select="collection()"/>
           </corpus>
         </xsl:template>
       ================================================================== -->

</xsl:stylesheet>
