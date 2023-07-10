<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

  <!--* chalmers-html.xsl:  display Chalmers data in HTML
      *
      * Quick and dirty stylesheet to produce adequate HTML.
      * I'd use Liam's but I don't have network connectivity
      * at the moment.
      *-->
  
  <!--* 
      * Copyright (C) 2020 Black Mesa Technologies LLC
      
      * This program is free software: you can redistribute it and/or
      * modify it under the terms of the GNU General Public License as
      * published by the Free Software Foundation, either version 3 of
      * the License, or (at your option) any later version.
      
      * This program is distributed in the hope that it will be useful,
      * but WITHOUT ANY WARRANTY; without even the implied warranty of
      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      * GNU General Public License for more details.
      
      * You should have received a copy of the GNU General Public
      * License along with this program, in the Licenses subdirectory,
      * in file GNU_GPL.
      
      * If the license was not provided, or is missing, see
      * <http://www.gnu.org/licenses/>.
      *-->

  <!--* Revisions:
      * 2020-03-29 : CMSMcQ : tweaks for test set 2
      * 2020-03-28 : CMSMcQ : works for test set 1 
      * 2020-03-27 : CMSMcQ : began transform, en route; pass Andrews Test
      *-->

  <!--****************************************************************
      * 1 Initializetion, setup. 
      ****************************************************************-->

  <!--*
  <xsl:output method="xhtml"
	      indent="yes"
	      html-version="5.0"
	      />
	      *-->

  <xsl:output method="html"
	      indent="yes"
	      />

  <xsl:strip-space elements="testcase entry body"/>

  <xsl:variable name="xhns"
		select=" 'http://www.w3.org/1999/xhtml' "/>
		
	      
  <!--****************************************************************
      * 2 Document root
      ****************************************************************-->
  
  <xsl:template match="/">
    <xsl:element name="html" namespace="{$xhns}">
      <xsl:element name="head" namespace="{$xhns}">
	<xsl:element name="title" namespace="{$xhns}">
	  <xsl:apply-templates select="descendant::title[1]"/>
	  <!--
	  <xsl:value-of
	  select="normalize-space(/descendant::title[1])"/>
	  -->
	  <!--* letter/title or entry/title *-->
	</xsl:element>
	<xsl:element name="style" namespace="{$xhns}">
	  <xsl:attribute name="type">text/css</xsl:attribute>
	  
	  <xsl:text>div.unknown {&#xA;</xsl:text>
	  <xsl:text>    color: red;&#xA;</xsl:text>
	  <xsl:text>    margin-left: 1em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>
	  
	  <xsl:text>h1.entry-title {&#xA;</xsl:text>
	  <xsl:text>    display: inline;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>
	  
	  <xsl:text>span.csc, span.sc {&#xA;</xsl:text>
	  <xsl:text>    font-variant: small-caps;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>
	  
	  <xsl:text>div.p {&#xA;</xsl:text>
	  <xsl:text>    margin: 1em 0em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>div.fn > div.p {&#xA;</xsl:text>
	  <xsl:text>    margin: 0em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>div.fn {&#xA;</xsl:text>
	  <xsl:text>    background-color:  #DDD;&#xA;</xsl:text>
	  <xsl:text>    padding: 0em 1em 0.5em 1em;&#xA;</xsl:text>
	  <xsl:text>    margin: 0em 0em 0em 2em;&#xA;</xsl:text>
	  <xsl:text>    font-size: small: 2em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>div.orphaned-note > div.fn {&#xA;</xsl:text>
	  <xsl:text>    border: 1px solid navy;&#xA;</xsl:text>
	  <xsl:text>    background-color:  #AEA;&#xA;</xsl:text>
	  <xsl:text>    margin: 1em 0em 1em 2em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>div.fn span.m {&#xA;</xsl:text>
	  <xsl:text>    display: inline-block;&#xA;</xsl:text>
	  <xsl:text>    padding-right: 0.3em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>a.fr {&#xA;</xsl:text>
	  <xsl:text>    display: inline-block;&#xA;</xsl:text>
	  <xsl:text>    color: navy;&#xA;</xsl:text>
	  <xsl:text>    padding-right: 0.3em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>span.page {&#xA;</xsl:text>
	  <xsl:text>    display: inline-block;&#xA;</xsl:text>
	  <xsl:text>    color: #A77;&#xA;</xsl:text>
	  <xsl:text>    padding: 0 0.3em;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>span.page > span.volnum, span.page > span.pagenum {&#xA;</xsl:text>
	  <xsl:text>    padding: 0 0.2em;&#xA;</xsl:text>
	  <xsl:text>    vertical-align: super;&#xA;</xsl:text>
	  <xsl:text>    font-size: x-small;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>span.source {&#xA;</xsl:text>
	  <xsl:text>    font-style: italic;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>span.q {&#xA;</xsl:text>
	  <xsl:text>    color: navy;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  <xsl:text>span.date {&#xA;</xsl:text>
	  <xsl:text>    color: #484;&#xA;</xsl:text>
	  <xsl:text>}&#xA;</xsl:text>

	  
	</xsl:element>
      </xsl:element>
      <xsl:element name="body" namespace="{$xhns}">
	<xsl:apply-templates/>
	<xsl:call-template name="orphaned-notes"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <!--****************************************************************
      * 3 Default display (red) 
      ****************************************************************-->

  <xsl:template match="*">
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class">unknown</xsl:attribute>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:for-each select="@*">
	<xsl:text> </xsl:text>
	<xsl:value-of select="name()"/>
	<xsl:text>="</xsl:text>
	<xsl:value-of select="string()"/>
	<xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:text>&gt;</xsl:text>
      
      <xsl:apply-templates/>
      
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt;</xsl:text>
    </xsl:element>
  </xsl:template>  

  <!--****************************************************************
      * 4 Document structure
      ****************************************************************-->

  <!--* ignore testcase wrapper *-->
  <xsl:template match="testcase">
    <xsl:apply-templates/>
  </xsl:template>

  <!--* Entry *-->
  <xsl:template match="entry"> 
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--* Entry/title *-->
  <xsl:template match="entry/title"/> 

  <!--* Entry/title *-->
  <xsl:template match="entry/title" mode="embedding"> 
    <xsl:element name="h1" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select=" 'entry-title'"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--* Entry body *-->
  <xsl:template match="body"> 
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--* First paragraph of entry body needs to pick up title *-->
  <xsl:template match="body/p[1]"> 
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/> first</xsl:attribute>      
      <xsl:apply-templates select="../../title" mode="embedding"/>
      <xsl:apply-templates/>
      <xsl:call-template name="handle-footnotes"/>
    </xsl:element>
  </xsl:template>

  <!--* First paragraph of footnote needs to pick up marker *-->
  <xsl:template match="fn/p[1]"> 
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/> first</xsl:attribute>      
      <xsl:apply-templates select="../m" mode="embedding"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--* Normal paragraphs *-->
  <xsl:template match="p"> 
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
      <xsl:call-template name="handle-footnotes"/>
    </xsl:element>
  </xsl:template>

  <!--* Some entries contain 'text' not a body with grafs *-->
  <xsl:template match="entry/text"> 
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class">entry-<xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates select="../title" mode="embedding"/>
      <xsl:text>&#xA;</xsl:text>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>  
  


  <!--****************************************************************
      * 5 Phrase-level elements
      ****************************************************************-->
  
  <!--* caps and small caps *-->
  <!--* these appear to be losing whitespace at both ends. *-->
  <xsl:template match="csc|sc">
    <xsl:if test="not(parent::title/parent::entry)">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:element name="span" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
    <xsl:if test="(1 = 0) and not(parent::title/parent::entry)">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!--* italics *-->
  <xsl:template match="i"> 
    <xsl:element name="i" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <!--* source references *-->
  <xsl:template match="source"> 
    <xsl:element name="span" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <!--* page boundaries *-->
  <xsl:template match="page">
    <xsl:variable name="imageref">
      <xsl:value-of
	  select="concat('http://words.fromoldbooks.org/i/c/',
		  @vol,
		  string(),
		  '.png')"/>
    </xsl:variable>
    <xsl:element name="a" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="$imageref"/></xsl:attribute>
      <xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute>
      <xsl:element name="span" namespace="{$xhns}">
	<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
	<xsl:element name="span" namespace="{$xhns}">
	  <xsl:attribute name="class">volnum</xsl:attribute>
	  <xsl:value-of select="@vol"/>
	</xsl:element>
	<xsl:text>|</xsl:text>
	<xsl:element name="span" namespace="{$xhns}">
	  <xsl:attribute name="class">pagenum</xsl:attribute>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <!--* column boundaries *-->
  <xsl:template match="col"> 
    <xsl:element name="span" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:text>&#x2551;</xsl:text>
    </xsl:element>
  </xsl:template>
  
  <!--* material in quotation marks *-->
  <xsl:template match="q"> 
    <xsl:element name="span" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <!--* marked dates *-->
  <xsl:template match="date"> 
    <xsl:element name="span" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <!--****************************************************************
      * 6 Footnotes and hypertext
      ****************************************************************-->

  <!--* in normal processing, footnote references become hyperlinks. *-->
  <xsl:template match="fr">
    <xsl:element name="a" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:attribute name="href">#<xsl:value-of select="@to"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--* at the end of each paragraph, we process fr again in order to print
      * the notes themselves. *-->
  <xsl:template match="fr" mode="gathering-notes">
    <xsl:variable name="fnid" select="@to"/>
    <xsl:variable name="fn" select="/descendant::fn[@id = $fnid]"/>
    <xsl:apply-templates select="$fn" mode="footnotes"/>
  </xsl:template>
  
  <xsl:template match="fn"/>
  
  <xsl:template match="fn" mode="footnotes">
    <xsl:element name="div" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      <xsl:if test="not(preceding-sibling::fn)">
	<xsl:attribute name="style"><xsl:value-of select=" 'padding-top:  0.5em; margin-top: 1em;' "/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="fn/m"/>
  <xsl:template match="fn/m" mode="footnotes"/>
  <xsl:template match="fn/m" mode="embedding">
    <xsl:element name="span" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="handle-footnotes">
    <!-- footnotes appear at their point of printing, so
	 usually in the middle of a different paragraph,
	 and not infrequently in the middle of a different
	 article.  We aren't going to deal here with notes
	 that are not present, but we do have to deal with
	 notes from a different article higher on the page.
    -->
    <xsl:apply-templates select="descendant::fr" mode="gathering-notes"/>	 
  </xsl:template>
  
  <xsl:template name="orphaned-notes">
    <xsl:for-each select="descendant::fn">
      <xsl:variable name="fnid" select="@id"/>
      <xsl:variable name="fnref" select="/descendant::fr[@to = $fnid]"/>
      <xsl:if test="not($fnref)">
	<xsl:element name="div" namespace="{$xhns}">
	  <xsl:attribute name="class"><xsl:value-of select="'orphaned-note'"/></xsl:attribute>
	  <xsl:apply-templates select="." mode="footnotes"/>
	</xsl:element>
      </xsl:if>
    </xsl:for-each>    
  </xsl:template>


  <!--****************************************************************
      * 7 Special cases
      ****************************************************************-->

  <xsl:template match="entry/title[csc]/text()[normalize-space() = '']"/>
  
</xsl:stylesheet>
