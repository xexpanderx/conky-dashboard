require 'cairo'

function hex2rgb(hex)
	if hex == nil then
		hex = "#404047"
	end

	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2))/255,
		   tonumber("0x"..hex:sub(3,4))/255,
		   tonumber("0x"..hex:sub(5,6))/255
end

function fix_text(text)
	if string.len(text) == 1 then
		local new_text = "0" .. text .. "%"
		return new_text
	else
		local new_text = text .. "%"
		return new_text
	end
end

function panel_background(cr, w, h)
    cairo_set_operator(cr,CAIRO_OPERATOR_OVER)
    cairo_set_source_rgba(cr, r0, g0, b0, t0_panel)
    cairo_move_to(cr,2,0)
	cairo_rel_line_to(cr,w-2,0)
	cairo_rel_line_to(cr,0,h)
	cairo_rel_line_to(cr,-w+2,0)
    cairo_close_path(cr)
	cairo_fill(cr)
end

function panel_border(cr, w, h)
	cairo_set_source_rgba(cr, r1, g1, b1, t1_border)
	cairo_move_to(cr,0,0)
	cairo_rel_line_to(cr,2,0)
	cairo_rel_line_to(cr,0,h)
	cairo_rel_line_to(cr,-2,0)
    cairo_close_path(cr)
	cairo_fill(cr)
end

function text_dimensions(cr, text, font, font_size)
	cairo_select_font_face (cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font_size)
	local ct = cairo_text_extents_t:create()
	cairo_text_extents(cr,text,ct)
	return ct
end

function draw_text(cr, r, g, b, t, text, x, y)
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_move_to(cr, x, y)
	cairo_show_text(cr, text)
end

function clock_and_date(cr, w, h)
	local clock = conky_parse('${exec date +%H:%M}')
	local date = conky_parse('${exec date +"%A - %d %B"}')

	-- ### Clock ###
	ct_clock = text_dimensions(cr, clock, "Overpass", 72)
	draw_text(cr, r2, g2, b2, t, clock, w/2-ct_clock.width/2, 76)
	-- ### Date ###
	ct_date = text_dimensions(cr, date, "Overpass", 18)
	draw_text(cr, r2, g2, b2, t, date, w/2-ct_date.width/2, 133)
end

function draw_weather(cr, w, h)
	icon_id = conky_parse("${exec tail -n1 ~/.conky/conky-dashboard/.weather.txt}")
	icon = icons[icon_id]
	if icon == nil then
		icon = ""
	end

	temp_c = conky_parse("${exec head -n1 ~/.conky/conky-dashboard/.weather.txt}")
	if tonumber(temp_c) ~= nil then
		temp_c = string.format("%.0f", temp_c)
		temp_c = temp_c .. "˚C"
	else
		temp_c = "N/A"
	end

	-- ### Weather icon ###
	ct_weather = text_dimensions(cr, icon, "Font Awesome 5 Pro Light", 92)
	draw_text(cr, r4, g4, b4, t, icon, w/2+20, ct_weather.height/2+ct_clock.height+ct_date.height+136)
	-- ### Temperature ###
 	ct_temperature = text_dimensions(cr, temp_c, "Overpass", 52)
	draw_text(cr, r2, g2, b2, t, temp_c, w/2-ct_temperature.width-20, ct_weather.height/2+ct_clock.height+ct_date.height-ct_temperature.height/2+142)
end

function check_updates(update)
	if update == nil then
		return ""
	else
		return update
	end
end

function check_icon_position(update)
	if update == nil then
		return 120
	else
		return update
	end
end

function draw_update(cr, update, text, font, font_size, font_icon, font_icon_size, text_x, text_y, icon_x, icon_y)
	text_dimensions(cr, text, font, font_size)
	r, g, b = hex2rgb(updates_text[update])
	draw_text(cr, r, g, b, t, text, text_x, text_y)

	icon = check_updates(updates[update])
	icon_pos = check_icon_position(updates_pos[update])
	text_dimensions(cr, icon, font_icon, font_icon_size)
	r, g, b = hex2rgb(updates_color[update])
	draw_text(cr, r, g, b, t, icon, icon_x + icon_pos, icon_y)
end

function draw_updates(cr, w, h)
	-- ### Border ###
	cairo_set_line_width(cr, 1)
	cairo_set_source_rgba(cr, r3, g3, b3, t)
	cairo_move_to(cr,2,300)
	cairo_rel_line_to(cr,w-2,0)
    cairo_close_path(cr)
	cairo_stroke(cr)

	-- ### Get updates ###
	slackpkg = conky_parse("${exec grep Slackpkg ~/.conky/conky-dashboard/.updates.txt | cut -d \":\" -f 2 | xargs}")
	sbopkg = conky_parse("${exec grep Sbopkg ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	linux = conky_parse("${exec grep Linux ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	skype = conky_parse("${exec grep Skype ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	chrome = conky_parse("${exec grep Google-Chrome ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	nvidia = conky_parse("${exec grep Nvidia ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")

	start_y = 380
	start_x_text = 57
	font = "Overpass"
	font_size = 18
	icon_font = "Font Awesome 5 Pro Solid"
	icon_font_size = 18
	-- ### Updates ###
	ct_updates = text_dimensions(cr, "Updates", font, font_size)
	draw_text(cr, r3, g3, b3, t, "Updates", w/2-ct_updates.width/2, start_y)
	start_y = start_y + 35
	-- ### Slackpkg ###
	draw_update(cr, slackpkg, "Slackpkg", font, font_size, icon_font, icon_font_size, start_x_text, start_y, w/2, start_y)
	-- ### sbopkg ###
	draw_update(cr, sbopkg, "Sbopkg", font, font_size, icon_font, icon_font_size, start_x_text, start_y+30, w/2,start_y+30)
	-- ### Linux ###
	draw_update(cr, linux, "Linux", font, font_size, icon_font, icon_font_size, start_x_text, start_y+60, w/2, start_y+60)
	-- ### Chrome ###
	draw_update(cr, chrome, "Chrome", font, font_size, icon_font, icon_font_size, start_x_text, start_y+90, w/2, start_y+90)
	-- ### Skype ###
	draw_update(cr, skype, "Skype", font, font_size, icon_font, icon_font_size, start_x_text, start_y+120, w/2, start_y+120)
	-- ### Nvidia ###
	draw_update(cr, nvidia, "Nvidia", font, font_size, icon_font, icon_font_size, start_x_text, start_y+150, w/2, start_y+150)
end

function draw_indicators(cr, w, h)
	start_y = 652
	start_x = 63
	font = "Font Awesome 5 Pro Light"
	font_size = 42

    -- ### HDD ###
	ct_hdd = text_dimensions(cr, "", font, font_size)
    draw_text(cr, r3, g3, b3, t, "", start_x,start_y + 15)

    fs_used = math.floor(10*tonumber(conky_parse("${fs_used_perc " .. "/" .. "}"))/100)
    for i=0, 10 do
		cairo_set_source_rgba(cr, r3, g3, b3, t)
		cairo_arc(cr,start_x+70+20*i,start_y,6,0*math.pi/180,360*math.pi/180)
		cairo_fill(cr)
    end
    for i=0, fs_used do
		cairo_set_source_rgba(cr, r4, g4, b4, t)
		cairo_arc(cr,start_x+70+20*i,start_y,6,0*math.pi/180,360*math.pi/180)
		cairo_fill(cr)
	end
    -- Battery
	battery_percentage = math.floor(10*tonumber(conky_parse("${battery_percent}"))/100)
	battery_status = conky_parse("${battery_short}")
	battery_status = string.sub(battery_status,1,1)
	text_dimensions(cr, "", font, font_size)

	if battery_status == "C" or battery_status == "F" then
		draw_text(cr, r3, g3, b3, t, "", start_x,start_y + 95)
	elseif battery_status == "D" then
		draw_text(cr, r3, g3, b3, t, "", start_x,start_y + 95)
	elseif battery_status == "F" then
		draw_text(cr, r3, g3, b3, t, "", start_x,start_y + 95)
	elseif battery_status == "U" then
		draw_text(cr, r3, g3, b3, t, "", start_x,start_y + 95)
	elseif battery_status == "E" then
		draw_text(cr, r3, g3, b3, t, "", start_x,start_y + 95)
	end

    for i=0, 10 do
    	cairo_set_source_rgba(cr, r3, g3, b3, t)
    	cairo_arc(cr,start_x+70+20*i,start_y+80,6,0*math.pi/180,360*math.pi/180)
    	cairo_fill(cr)
    end
    for i=0, battery_percentage do
    	cairo_set_source_rgba(cr, r4, g4, b4, t)
    	cairo_arc(cr,start_x+70+20*i,start_y+80,6,0*math.pi/180,360*math.pi/180)
    	cairo_fill(cr)
	end
	
	if battery_percentage < 2 then
		battery_percentage_string = conky_parse("${battery_percent}")
		io.popen("dunstify -a battery -i ~/.local/share/icons/Workspace/warning/exclamation-circle.svg \"Charge your battery! (" .. battery_percentage_string .. "%)\"")
	end

end
function draw_panel(cr, w, h)
    cairo_set_line_width(cr, 2)
    -- ### Panel ###
	panel_background(cr, w, h)
	-- ### Panel border ###
	panel_border(cr, w, h)
    -- ### Clock and date ###
	clock_and_date(cr, w, h)
	-- ### Weather ###
	draw_weather(cr, w, h)
	-- ### Updates ###
	draw_updates(cr, w, h)
    -- ### Indicators ###
	draw_indicators(cr, w, h)
end

function draw_widgets(cr)
	local w,h=conky_window.width,conky_window.height
	-- ### Api key ###
	api_key="[APIKEY]"
	-- ### City ###
	city="[CITY]"
	-- ### Country code ###
	ccode="[COUNTRYCODE]"
	-- ### Panel background ###
	color0="#20232C"
	-- ### Border background ###
	color1="#000000"
	-- ### Text colors ###
	color2="#A18673"
	-- ### Update border ###
	color3="#404047"
	-- ### Weather icon colors ###
	color4="#BE5C56"
	-- ### Other ###
	color5="#97B19C"

	r0, g0, b0 = hex2rgb(color0)
	r1, g1, b1 = hex2rgb(color1)
	r2, g2, b2 = hex2rgb(color2)
	r3, g3, b3 = hex2rgb(color3)
	r4, g4, b4 = hex2rgb(color4)
	r5, g5, b5 = hex2rgb(color5)
	-- ### Weather icons ###
 	icons = {}
	icons["50n"]=""
	icons["50d"]=""
	icons["13n"]=""
	icons["13d"]=""
	icons["11n"]=""
	icons["11d"]=""
	icons["10n"]=""
	icons["10d"]=""
	icons["09n"]=""
	icons["09d"]=""
	icons["04n"]=""
	icons["04d"]=""
	icons["03n"]=""
	icons["03d"]=""
	icons["02n"]=""
	icons["02d"]=""
	icons["01n"]=""
	icons["01d"]=""

	updates = {}
	updates["No updates available"]=""
	updates["Updates available"]=""

	updates_pos = {}
	updates_pos["No updates available"]=123
	updates_pos["Updates available"]=120

	updates_color = {}
	updates_color["No updates available"]=color3
	updates_color["Updates available"]=color4

	updates_text = {}
	updates_text["No updates available"]=color3
	updates_text["Updates available"]=color2
	-- ### Get coordinates of conky window and mouse ###
	x=tonumber(conky_parse("${exec xdotool search --name conky-dashboard | sed -n 1p | xargs xdotool getwindowgeometry --shell | grep 'X' | tr -d 'X='}"))
	y=tonumber(conky_parse("${exec xdotool search --name conky-dashboard | sed -n 1p | xargs xdotool getwindowgeometry --shell | grep 'Y' | tr -d 'Y='}"))
	mouse_x = tonumber(conky_parse("${exec xdotool getmouselocation --shell | grep 'X' | tr -d 'X='}"))
	mouse_y = tonumber(conky_parse("${exec xdotool getmouselocation --shell | grep 'Y' | tr -d 'Y='}"))

	if x ~= nil and y ~= nil and mouse_x ~= nil and mouse_y ~= nil then
		y_max = y+2
		x_max = x+w-10

		if mouse_x > x_max and mouse_y > y and mouse_y < y_max then
			t0_panel=1
			t1_border=0.1
			t=1
		else
			t0_panel=0
			t1_border=0
			t=0
		end

		draw_panel(cr, w, h)
	end
end

function conky_start_widgets()
	if conky_window==nil then return end
	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
	local cr=cairo_create(cs)
	--local ok, err = pcall(function () draw_widgets(cr) end)
	draw_widgets(cr)
	cairo_surface_destroy(cs)
	cairo_destroy(cr)
end