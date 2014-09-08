
TOOL.Category		= "Construction"
TOOL.Name			= "#Tool.acfcustom.listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "MobilityCustom"
TOOL.ClientConVar[ "id" ] = "1.0L-I4"

TOOL.ClientConVar[ "data1" ] = "1.0L-I4"
TOOL.ClientConVar[ "data2" ] = 0
TOOL.ClientConVar[ "data3" ] = 0
TOOL.ClientConVar[ "data4" ] = 0
TOOL.ClientConVar[ "data5" ] = 0
TOOL.ClientConVar[ "data6" ] = 0
TOOL.ClientConVar[ "data7" ] = 0
TOOL.ClientConVar[ "data8" ] = 0
TOOL.ClientConVar[ "data9" ] = 0
TOOL.ClientConVar[ "data10" ] = 0
--#####################################
TOOL.ClientConVar[ "data11" ] = 0
TOOL.ClientConVar[ "data12" ] = 0
TOOL.ClientConVar[ "data13" ] = 0
TOOL.ClientConVar[ "data14" ] = 0
TOOL.ClientConVar[ "data15" ] = 0
TOOL.ClientConVar[ "red" ] = 0
TOOL.ClientConVar[ "green" ] = 0
TOOL.ClientConVar[ "blue" ] = 0
--#####################################

cleanup.Register( "acfcustom" )

if CLIENT then	
	language.Add( "Tool.acfcustom.listname", "ACF Custom" )
	language.Add( "Tool.acfcustom.name", "ACF Custom V3" )
	language.Add( "Tool.acfcustom.desc", "Spawn the ACF Custom Entity" )
	language.Add( "Tool.acfcustom.0", "Left click to spawn the entity, Right click to link an entity to another (+Use to unlink)" )
	language.Add( "Tool.acfcustom.1", "Right click to link the selected sensor to a pod" )
	
	language.Add( "Undone_ACF Entity", "Undone ACF Entity" )
	language.Add( "Undone_acf_engine", "Undone ACF Engine" )
	language.Add( "Undone_acf_enginemaker", "Undone ACF Engine Maker" )
	language.Add( "Undone_acf_gearboxcvt", "Undone ACF Gearbox CVT" )
	language.Add( "Undone_acf_gearboxauto", "Undone ACF Gearbox Automatic" )
	language.Add( "Undone_acf_chips", "Undone ACF Engine Chips" )
	language.Add( "Undone_acf_vtec", "Undone ACF Vtec Chip" )
	language.Add( "Undone_acf_nos", "Undone ACF Nos Bottle" )

	/*------------------------------------
		BuildCPanel
	------------------------------------*/
	function TOOL.BuildCPanel( CPanel )
	
		local pnldef_ACFcustom = vgui.RegisterFile( "acf/client/cl_acfcustom_gui.lua" )
		
		// create
		local DPanel = vgui.CreateFromTable( pnldef_ACFcustom )
		CPanel:AddPanel( DPanel )
	
	end
end

-- Spawn/update functions
function TOOL:LeftClick( trace )

	if CLIENT then return true end
	if not IsValid( trace.Entity ) and not trace.Entity:IsWorld() then return false end
	
	local ply = self:GetOwner()
	local Type = self:GetClientInfo( "type" )
	local Id = self:GetClientInfo( "id" )
	
	local DupeClass = duplicator.FindEntityClass( ACFCUSTOM.Weapons[Type][Id]["ent"] ) 
	
	if DupeClass then
		local ArgTable = {}
			ArgTable[2] = trace.HitNormal:Angle():Up():Angle()
			ArgTable[1] = trace.HitPos + trace.HitNormal*32
			
		local ArgList = list.Get("ACFCvars")
		
		-- Reading the list packaged with the ent to see what client CVar it needs
		for Number, Key in pairs( ArgList[ACFCUSTOM.Weapons[Type][Id]["ent"]] ) do
			ArgTable[ Number+2 ] = self:GetClientInfo( Key )
		end
		
		if trace.Entity:GetClass() == ACFCUSTOM.Weapons[Type][Id]["ent"] and trace.Entity.CanUpdate then
			table.insert( ArgTable, 1, ply )
			local success, msg = trace.Entity:Update( ArgTable )
			ACFCUSTOM_SendNotify( ply, success, msg )
		else
			-- Using the Duplicator entity register to find the right factory function
			local Ent = DupeClass.Func( ply, unpack( ArgTable ) )
			Ent:Activate()
			Ent:GetPhysicsObject():Wake()
			
			undo.Create( ACFCUSTOM.Weapons[Type][Id]["ent"] )
				undo.AddEntity( Ent )
				undo.SetPlayer( ply )
			undo.Finish()
		end
			
		return true
	else
		print("Didn't find entity duplicator records")
	end

end

-- Link/unlink functions
function TOOL:RightClick( trace )

	if not IsValid( trace.Entity ) then return false end
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	
	if self:GetStage() == 0 and trace.Entity.IsMaster then
		self.Master = trace.Entity
		self:SetStage( 1 )
		return true
	elseif self:GetStage() == 1 then
		local success, msg
		
		if ply:KeyDown( IN_USE ) or ply:KeyDown( IN_SPEED ) then
			success, msg = self.Master:Unlink( trace.Entity )
		else
			success, msg = self.Master:Link( trace.Entity )
		end
		
		ACFCUSTOM_SendNotify( ply, success, msg )
		
		self:SetStage( 0 )
		self.Master = nil
		return true
	else
		return false
	end
	
end
