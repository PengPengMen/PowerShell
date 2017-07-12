Function ISE-ST3 {    
# powershell ise 字库，字体，字号，颜色 主题配色文件。
# 让powershell代码颜色像 著名编辑器 Sublime Text 3 一样。

#先安装“Monaco”，“Microsoft YaHei Mono”字库，这两种字库英文有差异，根据自己洗好选择。
#	$psISE.Options.FontName = 'Microsoft YaHei Mono'
#   $psISE.Options.FontSize = 18 
	$psISE.Options.FontName = 'consolab'
    $psISE.Options.FontSize = 16 
    $psISE.Options.ScriptPaneBackgroundColor = '#FF272822'
    $psISE.Options.TokenColors['Command'] = '#FFA6E22E'
    $psISE.Options.TokenColors['Unknown'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['Member'] = '#FF8B4513'
    $psISE.Options.TokenColors['Position'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['GroupEnd'] = '#FFF8F8F2'
#powershell 传教士 原创文章 2014-09-21，允许转载，但必须保留名字和出处，否则追究法律责任
#很多人，包括我，看着黑白的powershell代码抓图，感脚矮丑挫。
#我的目的就是让powershell代码，看起来高大上+悦目！
    $psISE.Options.TokenColors['GroupStart'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['LineContinuation'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['NewLine'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['StatementSeparator'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['Comment'] = '#FF75715E'
    $psISE.Options.TokenColors['String'] = '#FFE6DB74'
    $psISE.Options.TokenColors['Keyword'] = '#FF66D9EF'
    $psISE.Options.TokenColors['Attribute'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['Type'] = '#FFA6E22E'
    $psISE.Options.TokenColors['Variable'] = '#FFF8F8F2'
    $psISE.Options.TokenColors['CommandParameter'] = '#FFFD971F'
    $psISE.Options.TokenColors['CommandArgument'] = '#FFA6E22E'
    $psISE.Options.TokenColors['Number'] = '#FFAE81FF'
    $psISE.Options.TokenColors['Operator'] = '#FFF92672'
} 
ISE-ST3