module SiteHelpHelper
  def question_link(qtxt, id)
    "<a href='##{h id}' class='ques'>#{h qtxt}</a><br/>"
  end
  
  def answer_link(qtxt, atxt, id)
    %(<h2 id="#{h id}">#{h qtxt}</h2>
    #{simple_format atxt})
  end
  
  QUESTIONS = [
    {
      :qt => "WeFootball的菜单为什么在有些页面会变来变去？", 
      :at => %(在WeFootball中，我们提供了三种视角——个人视角、球队视角和比赛视角。根据所处视角的不同，菜单所给出的相应操作也各不相同。例如和球队相关的成员管理、训练、约战等功能都在球队视角的菜单中。 

可能开始的时候你需要一定时间来适应这种方式，但我们相信再经过一段时间的使用后你定能游刃有余。)  
    },
    {
      :qt => "球队阵型和比赛阵型是什么东东？", 
      :at => %(球队阵型给出了球队的主力成员以及站位情况，它是队伍信息的一部分，可以在队伍的设置菜单中进行设置。 

比赛阵型则是针对某场具体比赛排出的阵型。与球队阵型不同，在安排比赛阵型时，可选的列表中已经去除了不参加本场比赛的队员，另外还要比赛参加人数的限制（比如7人制的比赛就不能排出一个人数超过7人的阵型了）。 

最后，考虑到广大球队对于拉拉队、太太团方面的需求，我们目前在球队中区分了球员和非球员两类不同成员。排阵型时的备选列表一定是球员的子集。因此，如果你发现排阵型时没有可用的备选，可能需要考虑到“选拔队员”的菜单项里去提拔几个队员了~ 
)  
    },
    {
      :qt => "活动和时间有什么关系？", 
      :at => %(对于足球比赛活动来说，时间是一个重要的元素。你可能会注意到，随着时间的不同（活动开始前、活动进行中和活动结束后），一些提示链接（例如要去、去了）的内容会不断变化。 

特别是对于比赛和约战来说，在比赛结束以后会出现填写比赛结果的链接，这也是活动时序性的一个表现（那些比赛没结束就想填写结果的管理员，我们只能为其专业精神表示深深的遗憾了）。
)  
    },
    {
      :qt => "“没表态是否参加”是什么意思？", 
      :at => %(在球队活动（训练、比赛、约战）建立时，该队的所有队员会自动地被设置为“没表态是否参加状态”。处于这种状态的用户可以选择“参加这次活动”或“不参加这次活动”。

对于比赛和约战来说，没有明确表示不参加这次活动的用户都可以被排入到阵形中。因此，建议你在有确定意向后尽快更新一下自己的状态，无论去还是不去，这样可以有效地避免误会和冲突的发生。
)  
    },
    {
      :qt => "为什么我要去踢得地方不在场地选择列表中？我该如何是好？", 
      :at => %(目前WeFootball暂时还不支持用户自主提交球场（想想看北京大学第一体育场有多少种不同的叫法，如果有一天你的列表中塞满了一个个指向同一个场地的不同名称，你应该会相当不爽吧...）不过请注意，我们说的是“暂时”。请耐心的等待一下，不久的将来，你就可以将自己要去踢的球场又快又好的添加到列表中了。 

那么现在，当你想去踢球的场地确实不在列表中时，你可以点击下拉框边上的“场地不在列表中, 点击此处填写”链接，然后填写场地名称。
)  
    },
    {
      :qt => "如何邀请朋友使用WeFootball?", 
      :at => %(看到WeFootball页面左上角的"发邀请"链接了吗？点击这个链接，然后在出现的页面中填写受邀人的邮箱就可以给他发出邀请了。

当受邀人的帐户注册激活完毕后，你会和受邀人自动的成为朋友。如果你有管理的球队，你还可以直接选择邀请他加入球队。
)  
    },
    {
      :qt => "为什么个人或球队小图标下面的昵称被截短了?", 
      :at => %(这种问题发生在你使用英文昵称，且该昵称由连续12个左右的字母组成的情况。很遗憾，到目前为止，在我们所知道的范围内，这个问题尚无好的解决方案。

如果你不能忍这种情况而且确实不舍得把昵称变短，一个简单的变通方法是在现有的字母序列中加入空格。例如将realmadrid@wm改为realmadrid @wm后，该队名就可以完整的显示出来了。
)  
    },    
    {
      :qt => "为什么约战的比赛结果会有争议的情况?", 
      :at => %(虽然目前和谐已经成为我们这个时代的主旋律，但是毕竟球场上常有不测风云，可能是踢了场斗气球，可能是对方真的记错了比分——总之，当对方填写的比赛结果和你队并不相同时，比赛结果就显示为争议了。在这种情况下，双方不同版本的比赛结果会同时显示，究竟孰对孰错，公道自在心中了。 

当然，我们还是鼓励在约战中尽量引入第三方（比如裁判）。当然更重要的是，踢球只是一种运动，享受过程才是其真正的魅力，一个经常和各种队发生赛果争议的球队，其rp必然会受到相当大的影响。因此，WeFootball郑重呼吁：要和谐，要有爱。 
)  
    }          
  ]
  
  def question_links
    id = 1;
    content = ""
    QUESTIONS.each do |qu|
      content << question_link(qu[:qt], (qu[:id] || "id#{id}"))
      id +=1
    end
    content
  end
  
  def answer_links
    id = 1;
    content = ""
    QUESTIONS.each do |qu|
      content << answer_link(qu[:qt], qu[:at], (qu[:id] || "id#{id}"))
      id +=1
    end
    content
  end
end
