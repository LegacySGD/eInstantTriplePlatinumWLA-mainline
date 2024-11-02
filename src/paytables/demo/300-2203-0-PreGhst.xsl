<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						// RB,VH,NE,TG,SH,WW,PC,MD,QG,KJ,VD,UC,WW,QE,XA,OJ,LA,OF,KI,SF|            - Division 1
						// QJ,OG,KD,WW,MJ,LA,NF,TI,UF,WW,SB,RI,LG,PH,RB,TE,KD,WW,VE,PC|0X0ZXZ0MX   - Division 8
						var scenario = getScenario(jsonContext);
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var mainScenario = getOutcomeData(scenario);
						var bonusScenario = getBonusMoves(scenario);
						
						// Output winning numbers table.
						var r = [];
						var outcomeNum = 0;
						var bonusCount = 0;

						// debug info
					//	r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;overflow-x:scroll">');
					//	r.push(mainScenario + ", " + bonusScenario);
					//	r.push('</table>');
					//	r.push('<br>');

					//	r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;overflow-x:scroll">');
					//	r.push(getTranslationByName("skillMessage", translations));
					//	r.push('</table>');
					//	r.push('<br>');

						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;overflow-x:scroll">');

						r.push('<tr class="tablehead">');
						r.push('<td>');
						r.push(getTranslationByName("gem", translations));
						r.push('</td>');
						r.push('<td>');
						r.push(getTranslationByName("wins", translations));
						r.push('</td>');
						r.push('</tr>');

						for (var i in mainScenario)
						{
							r.push('<tr>');
						
							var prizeText = '';
							var playLetter = mainScenario[i][0];
							var prizeLetter = mainScenario[i][1];

							r.push('<td class="tablebody">');
							r.push(getTranslationByName(playLetter, translations));
							r.push('</td>');

							var winner = /[X-Z]/.exec(playLetter);

							if (prizeLetter == 'W')
							{
								bonusCount++;
							}
							else if (winner)
							{
								if (playLetter == 'X')
								{
									prizeText = 'x3';
								}
								else if (playLetter == 'Y')
								{
									prizeText = 'x2';
								}
								else if (playLetter == 'Z')
								{
									prizeText = 'x1';
								}
							}

							if (winner) 
							{
								r.push('<td class="tablebody">');
								if (prizeText.length > 0)
								{ 
									r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, prizeLetter)] + " " + prizeText);
								}
								else
								{
									r.push(prizeLetter);
								}
								r.push('</td>');
							}
							else
							{
								r.push('<td class="tablebody">');
								r.push(prizeText);
								r.push('</td>');
							}

							r.push('</tr>');
						}
						r.push('</table>');

						if (bonusCount >= 3)
						{
							r.push('<br>');

							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;overflow-x:scroll">');
							
							r.push('<tr class="tablehead">');
							r.push('<td>');
							r.push(getTranslationByName("bonusGame", translations) + " " + bonusCount + " " + getTranslationByName("rubies", translations));
							r.push('</td>');
							r.push('</tr>');

							r.push('<tr class="tablehead">');
							r.push('<td>');
							r.push(getTranslationByName("wheelPosition", translations));
							r.push('</td>');
							r.push('<td>');
							r.push(getTranslationByName("wins", translations));
							r.push('</td>');
							r.push('</tr>');

							for (var i in bonusScenario)
							{
								r.push('<tr>');
						
								var bonusPrize = "";
								var bonusPrizeLetter = bonusScenario[i][0];
								var bonusMatch = /[M-V]/.exec(bonusPrizeLetter);

								r.push('<td class="tablebody">');
								if (bonusMatch) 
								{
									bonusPrize = convertedPrizeValues[getPrizeNameIndex(prizeNames, bonusPrizeLetter)];
									r.push(bonusPrize);
								}
								else if (bonusPrizeLetter == 'X')
								{
									r.push(getTranslationByName("rubyRemoved", translations));
								}
								else if (bonusPrizeLetter == 'Z')
								{
									r.push(getTranslationByName("wheelAdvance", translations));
								}
								r.push('</td>');
								if (bonusMatch) 
								{
									r.push('<td class="tablebody">');
									r.push(bonusPrize);
									r.push('</td>');
								}

								r.push('</tr>');
							}
							r.push('</table>');
						}

						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
							
						}
						
						return r.join('');
					}
					
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");
						
						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}
						
						return "";
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "m11,m10,m9,m8,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{						
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					// Input: "QJ,OG,KD,WW,MJ,LA,NF,TI,UF,WW,SB,RI,LG,PH,RB,TE,KD,WW,VE,PC|0X0ZXZ0MX"
					// Output: ["QJ", "OG", "KD", "WW", ...]
					function getOutcomeData(scenario)
					{
						var outcomeData = scenario.split("|")[0];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i < outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i]); 
						}
						return result;
					}
					
					// Input: "QJ,OG,KD,WW,MJ,LA,NF,TI,UF,WW,SB,RI,LG,PH,RB,TE,KD,WW,VE,PC|0X0ZXZ0MX"
					// Output: ["0", "X", "0", ...]
					function getBonusMoves(scenario)
					{
						var numsData = scenario.split("|")[1];
						return numsData.split("");
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
