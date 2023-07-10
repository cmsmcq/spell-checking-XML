<!DOCTYPE xsl:stylesheet [
<!ENTITY lsquo  "&#x2018;" ><!--=single quotation mark, left-->
<!ENTITY rsquo  "&#x2019;" ><!--=single quotation mark, right-->
<!ENTITY ldquo  "&#x201C;" ><!--=double quotation mark, left-->
<!ENTITY rdquo  "&#x201D;" ><!--=double quotation mark, right-->
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:scx="http://blackmesatech.com/2020/ns/scx"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		version="3.0">

  <!--* chalmers-detokenizer.xsl:  return Chalmers data into its
      * original form.
      *
      * Quick and dirty stylesheet to produce adequate results.
      * No attempt will be made at generality, though after I've
      * handled Chalmers and a few other texts I have no objection
      * to trying to factor out comonalities.
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
      * 2023-07-10 : CMSMcQ : renamed from chalmers-detokenizer (but it's
      *                       still not general)
      * 2020-04-09 : CMSMcQ : began transform
      *-->

  <!--* elements with text-node siblings (bracketed element types do
      * not themselves have text-node children):
      *
      * a abbr acronym artist b [br] cite [col] county csc date em
      * [extract] fg fn fr greek h i la latin line m p page person
      * place q [qv] river sc small source span strong sup tt u w work
      *
      * Empty: br col
      * Crystal: extract (contains p)
      * Uncertain:  qv (one occurrence, ws to be inserted L, deleted R.
      *-->
    
  <!--****************************************************************
      * 1 Initializetion, setup. 
      ****************************************************************-->

  <xsl:output method="xml"
	      indent="no"
	      />

  <xsl:strip-space elements="*"/>
  
  <xsl:variable name="scxns"
		as="xs:string"
		select=" 'http://blackmesatech.com/2020/ns/scx' "/>
 
  
  <!--****************************************************************
      * 2 Document root
      ****************************************************************-->
  
  <xsl:template match="/">    
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="scx:flagged-document">
    <xsl:apply-templates select="scx:doc/*"/>
  </xsl:template>

  <xsl:template match="scx:flaglist"/>

  
  <!--****************************************************************
      * 3 Default identity transform
      ****************************************************************-->

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:if test="self::element() and not(parent::*)">
	<xsl:attribute name="scx:date" select="current-dateTime()"/>
      </xsl:if>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  

  <!--****************************************************************
      * 4 De-tokenization
      ****************************************************************-->

  <xsl:template match="scx:pc">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="scx:s">
    <xsl:variable name="lcp" as="xs:integer*"
		  select="for $n in tokenize(., '\s+')
			  return xs:integer($n)"/>
    <xsl:variable name="s" as="xs:string"
		  select="codepoints-to-string($lcp)"/>
    <xsl:value-of select="$s"/>
  </xsl:template>
  
  <xsl:template match="scx:w">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="scx:w[@scx:note='non-checkable']">
    <xsl:element name="sic">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  <!--****************************************************************
      * 5 Phrase-level elements
      ****************************************************************-->
 

  <!--****************************************************************
      * 6 Footnotes and hypertext
      ****************************************************************-->

  <!--****************************************************************
      * 7 Special cases
      ****************************************************************-->
  
</xsl:stylesheet>
