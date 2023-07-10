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

  <!--* tokenizer.xsl:  break XML data into words for checking
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
      * 2023-07-10 : CMSMcQ : rename from chalmers-tokenizer.xsl (but not
      *                       yet general-purpose)
      * 2020-03-28 : CMSMcQ : began transform, in Union Station, Chicago
      *                       Work plan:
      *                       . base identity transform (done)
      *                       . assume every element causes a word boundary;
      *                         tokenize every text() node
      *                       . find a way to handle csc and i as intra-word
      *                       . tokenize selected attributes
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
	      indent="yes"
	      />
  <xsl:strip-space elements="scx:*"/>
  
  <xsl:variable name="scxns"
		as="xs:string"
		select=" 'http://blackmesatech.com/2020/ns/scx' "/>

  <!--* Sets of characters. *-->
  <!--* Punc:  all punctuation marks we can see in the data and on the keyboard *-->
  <xsl:variable name="csPunc"
		as="xs:string"
		select="concat(
			'\(\)',
			'\[\]',
			'\{\}',
			'~`!@#$%^&amp;\*\-_\+=',
			'\|\\',
			':;&apos;&apos;&quot;&quot;',
			',&lt;.&gt;/\?',
			'&ldquo;&lsquo;',
			'&ldquo;&rdquo;&lsquo;&rsquo;'
			)"/>
  
  <!--* Punctuation sequences. *-->
  <xsl:variable name="rePunc"
		as="xs:string"
		select="concat('[', $csPunc, ']+')"/>
  
  <!--* Non-punctuation sequences. *-->
  <xsl:variable name="reNonPunc"
		as="xs:string"
		select="concat('([^', $csPunc, ']|\s)+')"/>
  
  <!--* Token with leading punctuation. *-->
  <xsl:variable name="reLToken"
		as="xs:string"
		select="concat('^(', $rePunc, ')(', $reNonPunc, '.*)$')"/>
  
  <!--* Token with following punctuation. *-->
  <xsl:variable name="reFToken"
		as="xs:string"
		select="concat('^(.*', $reNonPunc, ')(', $rePunc, '$)')"/>
 
  
  <!--****************************************************************
      * 2 Document root
      ****************************************************************-->
  
  <xsl:template match="/">    
    <xsl:apply-templates/>
  </xsl:template>
  
  
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
      * 4 Tokenization
      ****************************************************************-->
  <xsl:template match="text()" priority="10">
    <xsl:variable name="textnode" as="text()" select="."/>
    <xsl:analyze-string select="." regex="\s+">
      <xsl:matching-substring>
	<xsl:element name="scx:s">
	  <xsl:attribute name="n"
			 select="position()"/>
	  <xsl:value-of select="string-to-codepoints(.)"/>
	</xsl:element>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
	<xsl:variable name="catLeft" as="xs:boolean"
		      select="position() eq 1"/>
	<xsl:variable name="catRight" as="xs:boolean"
		      select="position() eq last()"/>
	<xsl:choose>
	  <!--* Simple case 1:  just letters and numbers *-->
	  <xsl:when test="matches(., '^([a-zA-Z0-9]+)$') ">
	    <xsl:element name="scx:w">
	      <xsl:if test="$catLeft or $catRight">
		<xsl:attribute name="join">
		  <xsl:value-of select="if ($catLeft and $catRight)
		    then 'both'
		    else if ($catLeft)
		    then 'left'
		    else if ($catRight)
		    then 'right'
		    else 'om-tont-ho'"/>
		</xsl:attribute>
	      </xsl:if>
	      <xsl:value-of select="."/>
	    </xsl:element>
	  </xsl:when>
	  <!--* Simple case 2:  just punctuation *-->
	  <xsl:when test="matches(., concat('^(',$rePunc, ')$'))">
	    <xsl:element name="scx:pc">
	      <xsl:if test="$catLeft or $catRight">
		<xsl:attribute name="join">
		  <xsl:value-of select="if ($catLeft and $catRight)
		    then 'both'
		    else if ($catLeft)
		    then 'left'
		    else if ($catRight)
		    then 'right'
		    else 'om-tont-ho'"/>
		</xsl:attribute>
	      </xsl:if>
	      <xsl:value-of select="."/>
	    </xsl:element>
	  </xsl:when>
	  
	  <!--* Case 3:  leading punctuation or following punctuation *-->
	  <xsl:when test="matches(., $reLToken) or matches(., $reFToken)">
	    <xsl:variable name="pcLeft"
			  as="xs:string"
			  select="if (matches(., $reLToken))
				  then replace(., $reLToken, '$1')
				  else ''"/>
	    <xsl:variable name="sCenterRight"
			  as="xs:string"
			  select="if (matches(., $reLToken))
				  then replace(., $reLToken, '$2')
				  else ."/>
	    <xsl:variable name="sCenter"
			  as="xs:string"
			  select="if (matches(., $reFToken))
				  then replace($sCenterRight, $reFToken, '$1')
				  else $sCenterRight"/>
	    <xsl:variable name="pcRight"
			  as="xs:string"
			  select="if (matches(., $reFToken))
				  then replace($sCenterRight, $reFToken, '$3')
				  else ''"/>
	    
	    <xsl:if test=". ne concat($pcLeft, $sCenter, $pcRight)">
	      <xsl:message>Banzai!!! string is <xsl:value-of select="."/>
	      matches(., reLToken) = <xsl:value-of select="matches(., $reLToken)"/>
	      matches(., reFToken) = <xsl:value-of select="matches(., $reFToken)"/> 
	      pcLeft = |||<xsl:value-of select="$pcLeft"/>|||
              sCenterRight = |||<xsl:value-of select="$sCenterRight"/>||| 
	      sCenter = |||<xsl:value-of select="$sCenter"/>|||
	      pcRight = |||<xsl:value-of select="$pcRight"/>|||
	      </xsl:message>
	    </xsl:if>
	    <xsl:if test=". eq ''">
	      <xsl:message>Empty string here!!!</xsl:message>
	    </xsl:if>
	    
	    <xsl:if test="$pcLeft ne ''">
	      <xsl:element name="scx:pc">
		<xsl:attribute name="join">
		  <xsl:value-of select="if ($catLeft)
					then 'both'
					else 'right'"/>
		</xsl:attribute>
		<xsl:value-of select="$pcLeft"/>
	      </xsl:element>
	    </xsl:if>
	    <xsl:if test="$sCenter ne ''">
	      <xsl:element name="scx:w">
		<xsl:attribute name="join">
		  <xsl:variable name="fLeft" as="xs:boolean"
				select="($pcLeft ne '') or $catLeft"/>
		  <xsl:variable name="fRight" as="xs:boolean"
				select="($pcRight ne '') or $catRight"/>
		  <xsl:value-of select="if ($fLeft and $fRight)
					then 'both'
					else if ($fLeft)
					then 'left'
					else if ($fRight)
					then 'right'
					else 'yowser!'"/>
		</xsl:attribute>
		<xsl:value-of select="$sCenter"/>
	      </xsl:element>
	    </xsl:if>
	    <xsl:if test="$pcRight ne ''">
	      <xsl:element name="scx:pc">
		<xsl:attribute name="join">
		  <xsl:value-of select="if ($catRight)
					then 'both'
					else 'left'"/>
		</xsl:attribute>
		<xsl:value-of select="$pcRight"/>
	      </xsl:element>
	    </xsl:if>	    
	  </xsl:when>
	  
	  <!-- anything else, probably internal punctuation -->
	  <xsl:otherwise>
	    <xsl:element name="scx:w">
	      <xsl:if test="$catLeft or $catRight">
		<xsl:attribute name="join">
		  <xsl:value-of select="if ($catLeft and $catRight)
		    then 'both'
		    else if ($catLeft)
		    then 'left'
		    else if ($catRight)
		    then 'right'
		    else 'om-tont-ho'"/>
		</xsl:attribute>
	      </xsl:if>
	      <xsl:attribute name="scx:trace" select=" 'wpc' "/>
	      <xsl:value-of select="."/>
	    </xsl:element>	   
	  </xsl:otherwise>
	</xsl:choose>
	<!--
	<xsl:element name="scx:token">
	  <xsl:attribute name="n"
			 select="position()"/>
	  <xsl:if test="position() eq last()">
	    <xsl:attribute name="loc"
			   select=" 'last'"/>
	  </xsl:if>
	  <xsl:if test="(position() eq 1) or (position() eq last())">
	    <xsl:attribute name="join">
	      <xsl:choose>
		<xsl:when test="position() eq 1 and position() eq last()">
		  <xsl:value-of select=" 'both' "/>
		</xsl:when>
		<xsl:when test="position() eq 1">
		  <xsl:value-of select=" 'left' "/>
		</xsl:when>
		<xsl:when test="position() eq last()">
		  <xsl:value-of select=" 'right' "/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select=" 'what-on-earth?' "/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:value-of select="."/>
	</xsl:element>
	-->
      </xsl:non-matching-substring>
    </xsl:analyze-string>
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
