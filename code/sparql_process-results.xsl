<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sp="http://www.w3.org/2005/sparql-results#"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <table>
        <xsl:for-each-group select="descendant::sp:result" group-by="sp:binding[@name = 'format']/sp:uri">
            <xsl:variable name="v_format-url" select="current-grouping-key()"/>
            <xsl:for-each-group select="current-group()" group-by="sp:binding[@name = 'formatShortName']/sp:literal">
                <xsl:variable name="v_format-short" select="current-grouping-key()"/>
                <xsl:for-each-group select="current-group()/sp:binding[@name = 'formatName']" group-by="sp:literal">
                    <row>
                        <cell><xsl:value-of select="$v_format-url"/></cell>
                        <cell><xsl:value-of select="$v_format-short"/></cell>
                        <cell><xsl:value-of select="current-grouping-key()"/></cell>
                    </row>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:for-each-group>
        </table>
    </xsl:template>
    
</xsl:stylesheet>