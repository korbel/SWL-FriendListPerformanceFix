import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.Friends;
import com.GameInterface.Guild.Guild;

import lp.friendlistfix.utils.StringUtils;

class lp.friendlistfix.Main {
	
    private static var s_app:Main;
	
	private static var HOOK_CHECK_INTERVAL:Number = 100;
	private static var AUTO_REFRESH_DELAY:Number = 500;

    private var m_swfRoot:MovieClip;
	
	private var m_guildHookInterval:Number;
	private var m_friendsHookInterval:Number;
	private var m_ignoredHookInterval:Number;
	private var m_windowHookInterval:Number;
	private var m_membersManagementHookInterval:Number;
	
	private var RefreshFriendWindowSignal:Signal = new Signal();

    public static function main(swfRoot:MovieClip) {
		s_app = new Main(swfRoot);
		
		swfRoot.onLoad = function() { Main.s_app.OnLoad(); };
		swfRoot.OnUnload = function() { Main.s_app.OnUnload(); };
	}

    public function Main(swfRoot: MovieClip) {
        m_swfRoot = swfRoot;
    }
	
	public function OnLoad() {
		m_guildHookInterval = setInterval(Delegate.create(this, HookGuildView), HOOK_CHECK_INTERVAL);
		m_friendsHookInterval = setInterval(Delegate.create(this, HookFriendsView), HOOK_CHECK_INTERVAL);
		m_ignoredHookInterval = setInterval(Delegate.create(this, HookIgnoredView), HOOK_CHECK_INTERVAL);
		m_windowHookInterval = setInterval(Delegate.create(this, HookFriendsContainer), HOOK_CHECK_INTERVAL);
		m_membersManagementHookInterval = setInterval(Delegate.create(this, HookCabalMembersManagement), HOOK_CHECK_INTERVAL);
		
		ManualRefreshHooks();
    }

    public function OnUnload() {
		if (m_guildHookInterval) clearInterval(m_guildHookInterval);
		if (m_friendsHookInterval) clearInterval(m_friendsHookInterval);
		if (m_ignoredHookInterval) clearInterval(m_ignoredHookInterval);
		if (m_windowHookInterval) clearInterval(m_windowHookInterval);
		if (m_membersManagementHookInterval) clearInterval(m_membersManagementHookInterval);
    }
	
	private function HookGuildView() {
		var proto:Object = _global.GUI.Friends.Views.GuildView.prototype;
		if (proto) {
			var wrapper:Function = function():Void {
				arguments.callee.base.apply(this, arguments);
				Main.s_app.GuildSignalRedirect(this);
			};
			wrapper.base = proto.configUI;
			proto.configUI = wrapper;
			if (_root.friends.m_Window.m_Content.m_ViewsContainer.m_GuildView instanceof _global.GUI.Friends.Views.GuildView) {
				GuildSignalRedirect(_root.friends.m_Window.m_Content.m_ViewsContainer.m_GuildView);
			}
			clearInterval(m_guildHookInterval);
			m_guildHookInterval = null;
		}
	}
	
	private function HookFriendsView() {
		var proto:Object = _global.GUI.Friends.Views.FriendsView.prototype;
		if (proto) {
			var wrapper:Function = function():Void {
				arguments.callee.base.apply(this, arguments);
				Main.s_app.FriendsSignalRedirect(this);
			};
			wrapper.base = proto.configUI;
			proto.configUI = wrapper;
			if (_root.friends.m_Window.m_Content.m_ViewsContainer.m_FriendsView instanceof _global.GUI.Friends.Views.FriendsView) {
				FriendsSignalRedirect(_root.friends.m_Window.m_Content.m_ViewsContainer.m_FriendsView);
			}
			clearInterval(m_friendsHookInterval);
			m_friendsHookInterval = null;
		}
	}
	
	private function HookIgnoredView() {
		var proto:Object = _global.GUI.Friends.Views.IgnoredView.prototype;
		if (proto) {
			var wrapper:Function = function():Void {
				arguments.callee.base.apply(this, arguments);
				Main.s_app.IgnoredSignalRedirect(this);
			};
			wrapper.base = proto.configUI;
			proto.configUI = wrapper;
			if (_root.friends.m_Window.m_Content.m_ViewsContainer.m_IgnoredView instanceof _global.GUI.Friends.Views.IgnoredView) {
				IgnoredSignalRedirect(_root.friends.m_Window.m_Content.m_ViewsContainer.m_IgnoredView);
			}
			clearInterval(m_ignoredHookInterval);
			m_ignoredHookInterval = null;
		}
	}
	
	private function HookFriendsContainer() {
		var proto:Object = _global.GUI.Friends.FriendsContent.prototype;
		if (proto) {
			var wrapper:Function = function():Void {
				Main.s_app.AddRefreshButton(this);
				arguments.callee.base.apply(this, arguments);
			};
			wrapper.base = proto.configUI;
			proto.configUI = wrapper;
			if (_root.friends.m_Window.m_Content instanceof _global.GUI.Friends.FriendsContent) {
				AddRefreshButton(_root.friends.m_Window.m_Content);
			}
			clearInterval(m_windowHookInterval);
			m_windowHookInterval = null;
		}
	}
	
	private function HookCabalMembersManagement() {
		var proto:Object = _global.GUI.CabalManagement.CabalMembers.prototype;
		if (proto) {
			var wrapper:Function = function():Void {
				arguments.callee.base.apply(this, arguments);
				Main.s_app.MembersUpdateSignalRedirect(this);
			};
			wrapper.base = proto.configUI;
			proto.configUI = wrapper;
			if (_root.cabalmanagement.m_GuildWindow.m_ViewStack.currentView instanceof _global.GUI.CabalManagement.CabalMembers) {
				MembersUpdateSignalRedirect(_root.cabalmanagement.m_GuildWindow.m_ViewStack.currentView);
				HookMemberListItemRenderer(_root.cabalmanagement.m_GuildWindow.m_ViewStack.currentView());
			} else {
				HookMemberListItemRenderer();
			}
			clearInterval(m_membersManagementHookInterval);
			m_membersManagementHookInterval = null;
		}
	}
	
	private function RefreshButtonClickHandler() {
		RefreshFriendWindowSignal.Emit();
	}
	
	private function GuildSignalRedirect(guildView) {
		Friends.SignalGuildUpdated.Disconnect(guildView.SlotGuildUpdate, guildView);
		RefreshFriendWindowSignal.Connect(guildView.SlotGuildUpdate, guildView);
	}
	
	private function FriendsSignalRedirect(friendView) {
		Friends.SignalFriendsUpdated.Disconnect(friendView.SlotFriendsUpdate, friendView);
		RefreshFriendWindowSignal.Connect(friendView.SlotFriendsUpdate, friendView);
	}
	
	private function IgnoredSignalRedirect(ignoredView) {
		Friends.SignalIgnoreListUpdated.Disconnect(ignoredView.SlotIgnoredUpdate, ignoredView);
		RefreshFriendWindowSignal.Connect(ignoredView.SlotIgnoredUpdate, ignoredView);
	}
	
	private function MembersUpdateSignalRedirect(membersManagement) {
		Guild.GetInstance().SignalMembersUpdate.Disconnect(membersManagement.SlotMemberUpdated, membersManagement);
		RefreshFriendWindowSignal.Connect(membersManagement.SlotMemberUpdated, membersManagement);
	}
	
	private function HookMemberListItemRenderer(membersManagement) {
		var proto = _global.GUI.CabalManagement.MembersListItemRenderer.prototype;
		var wrapper:Function = function(data:Object):Void {
			arguments.callee.base.call(this, data);
			var onlineDate:Date = new Date(data.lastOnline);
			var dateStr:String = StringUtils.LeftPadding((onlineDate.getMonth() + 1).toString(), "0", 2)
				+ "/" + StringUtils.LeftPadding(onlineDate.getDate().toString(), "0", 2)
				+ "/" + StringUtils.LeftPadding((onlineDate.getFullYear() % 100).toString(), "0", 2);
			this.m_Status.text = (this.m_StatusBool) ? LDBFormat.LDBGetText("FriendsGUI", "statusOnline") : dateStr;
		};
		wrapper.base = proto.setData;
		proto.setData = wrapper;
		if (membersManagement) {
			membersManagement.m_MembersScrollingList.invalidateData();
		}
	}
	
	private function AddRefreshButton(friendsContent) {
		var m_RefreshButton = friendsContent.attachMovie("ChromeButtonWhite", "m_RefreshButton", friendsContent.getNextHighestDepth());
		m_RefreshButton.label = "REFRESH";
		m_RefreshButton._x = 0;
		m_RefreshButton._y = friendsContent._height - m_RefreshButton._height - 1;
		m_RefreshButton.addEventListener("click", this, "RefreshButtonClickHandler");
	}
	
	private function ManualRefreshHooks() {
		var AddFriend = Friends.AddFriend;
		Friends.AddFriend = function():Void {
			AddFriend.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
		}
		
		var RemoveFriend = Friends.RemoveFriend;
		Friends.RemoveFriend = function():Void {
			RemoveFriend.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
		}
		
		var PromoteGuildMember = Friends.PromoteGuildMember;
		Friends.PromoteGuildMember = function():Void {
			PromoteGuildMember.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
		}
		
		var DemoteGuildMember = Friends.DemoteGuildMember;
		Friends.DemoteGuildMember = function():Void {
			DemoteGuildMember.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
		}
		
		var RemoveFromGuild = Friends.RemoveFromGuild;
		Friends.RemoveFromGuild = function():Void {
			RemoveFromGuild.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
		}
		
		var Ignore = Friends.Ignore;
		Friends.Ignore = function():Boolean {
			var result = Ignore.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
			return result;
		}
		
		var Unignore = Friends.Unignore;
		Friends.Unignore = function():Boolean {
			var result = Unignore.apply(null, arguments);
			setTimeout(Delegate.create(Main.s_app, Main.s_app.RefreshButtonClickHandler), Main.AUTO_REFRESH_DELAY);
			return result;
		}
	}
}