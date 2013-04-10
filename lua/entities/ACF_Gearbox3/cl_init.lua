include("shared.lua")

ENT.RenderGroup 		= RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true
local maxtorque = 0  -- this is for the max torque output on the tooltip - Wrex
function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()
    Wire_Render(self.Entity)
end

function ENT:DoNormalDraw()
	local e = self.Entity
	if (LocalPlayer():GetEyeTrace().Entity == e and EyePos():Distance(e:GetPos()) < 256) then
		if(self:GetOverlayText() ~= "") then
			AddWorldTip(e:EntIndex(),self:GetOverlayText(),0.5,e:GetPos(),e)
		end
	end
end

function ENT:GetOverlayText()
	local name = self.Entity:GetNetworkedString("WireName")
	local Type = self.Entity:GetNetworkedBeamString("Type")
	local Weight = self.Entity:GetNetworkedBeamInt("Weight")
	local Current = self.Entity:GetNetworkedBeamInt("Current")
	local Declutch = self.Entity:GetNetworkedBeamInt("Declutch")
	local RpmMin = self.Entity:GetNetworkedBeamInt("RpmMin")
	local RpmMax = self.Entity:GetNetworkedBeamInt("RpmMax")
	
	
	local txt = Type.."\nWeight : "..Weight.."Kg\nCurrent Gear : "..Current.."\nDeclutch Rpm : "..Declutch.."RPM\nRpm Min : "..RpmMin.."RPM\nRpm Max : "..RpmMax.."RPM\nMaximum Torque Rating: "..(maxtorque).."n-m / "..math.Round(maxtorque*0.73).."ft-lb/n" or ""
	if (not game.SinglePlayer()) then
		local PlayerName = self:GetPlayerName()
		txt = txt .. "\n(" .. PlayerName .. ")"
	end
	if(name and name ~= "") then
	    if (txt == "") then
	        return "- "..name.." -"
	    end
	    return "- "..name.." -\n"..txt
	end
	return txt
end
--usermessage.Hook( "ACFGearbox_SendRatios", ACFGearboxCreateDisplayString )

function ACFGearbox3GUICreate( Table )

	if not acfmenupanel.GearboxData then
		acfmenupanel.GearboxData = {}
	end
	if not acfmenupanel.GearboxData[Table.id] then
		acfmenupanel.GearboxData[Table.id] = {}
		acfmenupanel.GearboxData[Table.id]["GearTable"] = Table.geartable
	end
		
	--#######################
	--acfmenupanel:CPanelText("Name", Table.name)
	TextName = vgui.Create( "DLabel" )
		TextName:SetText( "Name : "..Table.name)
		TextName:SetTextColor(Color(0,0,200,255))
		TextName:SetFont( "CloseCaption_BoldItalic" )
	acfmenupanel.CustomDisplay:AddItem( TextName )
	
	acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
		acfmenupanel.CData.DisplayModel:SetModel( Table.model )
		acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250 , 500 , 250 ) )
		acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
		acfmenupanel.CData.DisplayModel:SetFOV( 20 )
		acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
		acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel , entity ) end
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
	
	--acfmenupanel:CPanelText("Desc", Table.desc)
	TextDesc = vgui.Create( "DLabel" )
		TextDesc:SetText( "Desc : "..Table.desc)
		TextDesc:SetTextColor(Color(0,0,200,255))
		TextDesc:SetFont( "DefaultBold" )
	acfmenupanel.CustomDisplay:AddItem( TextDesc )
	
	for ID,Value in pairs(acfmenupanel.GearboxData[Table.id]["GearTable"]) do
		if ID > 0 and ID < 6 then
			ACF_AutoSlider1(ID, Value, Table.id)
		elseif ID == 6 then
			ACF_AutoSlider2(6, Value, Table.id, "Reverse Gear")
		elseif ID == 7 then
			ACF_AutoSlider3(7, Value, Table.id, "Declutch Rpm")
		elseif ID == 8 then
			ACF_AutoSlider4(8, Value, Table.id, "Minimum Rpm")
		elseif ID == 9 then
			ACF_AutoSlider5(9, Value, Table.id, "Maximum Rpm")
		elseif ID == -1 then
			ACF_AutoSlider6(10, Value, Table.id, "Final Drive")
		end
	end
	
	--acfmenupanel:CPanelText("Desc", Table.desc)
	--acfmenupanel:CPanelText("MaxTorque", "Clutch Maximum Torque Rating : "..(Table.maxtq).."n-m / "..math.Round(Table.maxtq*0.73).."ft-lb")
	TextTorque = vgui.Create( "DLabel" )
		TextTorque:SetText( "Max Torque Rating : "..(Table.maxtq).."n-m / "..math.Round(Table.maxtq*0.73).."ft-lb")
		TextTorque:SetTextColor(Color(0,0,200,255))
		TextTorque:SetFont( "DefaultBold" )
	acfmenupanel.CustomDisplay:AddItem( TextTorque )
	--acfmenupanel:CPanelText("Weight", "Weight : "..(Table.weight).." kg")
	TextWeight = vgui.Create( "DLabel" )
		TextWeight:SetText( "Weight : "..(Table.weight).." kg")
		TextWeight:SetTextColor(Color(0,0,200,255))
		TextWeight:SetFont( "DefaultBold" )
	acfmenupanel.CustomDisplay:AddItem( TextWeight )
	
	acfmenupanel.CustomDisplay:PerformLayout()
	maxtorque = Table.maxtq
end

function ACF_AutoSlider1(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Gear "..Gear )
			acfmenupanel["CData"][Gear]:SetMin( 0.01 )
			acfmenupanel["CData"][Gear]:SetMax( 1 )
			acfmenupanel["CData"][Gear]:SetDecimals( 2 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end

function ACF_AutoSlider2(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Reverse Gear" )
			acfmenupanel["CData"][Gear]:SetMin( -1 )
			acfmenupanel["CData"][Gear]:SetMax( -0.01 )
			acfmenupanel["CData"][Gear]:SetDecimals( 2 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end

function ACF_AutoSlider3(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Declutch Rpm" )
			acfmenupanel["CData"][Gear]:SetMin( 1000 )
			acfmenupanel["CData"][Gear]:SetMax( 4000 )
			acfmenupanel["CData"][Gear]:SetDecimals( 0 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end

function ACF_AutoSlider4(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Minimum Rpm" )
			acfmenupanel["CData"][Gear]:SetMin( 2000 )
			acfmenupanel["CData"][Gear]:SetMax( 6000 )
			acfmenupanel["CData"][Gear]:SetDecimals( 0 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end

function ACF_AutoSlider5(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Maximum Rpm" )
			acfmenupanel["CData"][Gear]:SetMin( 4000 )
			acfmenupanel["CData"][Gear]:SetMax( 15000 )
			acfmenupanel["CData"][Gear]:SetDecimals( 0 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end

function ACF_AutoSlider6(Gear, Value, ID, Desc)

	if Gear and not acfmenupanel["CData"][Gear] then	
		acfmenupanel["CData"][Gear] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Gear]:SetText( Desc or "Final Drive" )
			acfmenupanel["CData"][Gear]:SetMin( 0.05 )
			acfmenupanel["CData"][Gear]:SetMax( 1 )
			acfmenupanel["CData"][Gear]:SetDecimals( 2 )
			acfmenupanel["CData"][Gear]["Gear"] = Gear
			acfmenupanel["CData"][Gear]["ID"] = ID
			acfmenupanel["CData"][Gear]:SetValue(Value)
			RunConsoleCommand( "acfmenu_data"..Gear, Value )
			acfmenupanel["CData"][Gear].OnValueChanged = function( slider, val )
				acfmenupanel.GearboxData[slider.ID]["GearTable"][slider.Gear] = val
				RunConsoleCommand( "acfmenu_data"..Gear, val )
			end
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Gear] )
	end

end