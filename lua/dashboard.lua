require 'cairo'

function hex2rgb(hex)
	if hex ~= nil then
		hex = hex:gsub("#","")
		return (tonumber("0x"..hex:sub(1,2))/255), (tonumber("0x"..hex:sub(3,4))/255), tonumber(("0x"..hex:sub(5,6))/255)
	end
end

function fix_text(text)
	if string.len(text) == 1 then
		new_text = "0" .. text .. "%"
		return new_text
	else
		new_text = text .. "%"
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

function clock_and_date(cr, w, h)

	clock = conky_parse('${exec date +%H:%M}')
	date = conky_parse('${exec date +"%A - %d %B"}')

	--Clock
    cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_source_rgba(cr, r2, g2, b2, t)
	cairo_set_font_size(cr, 72)
	ct_clock = cairo_text_extents_t:create()
	cairo_text_extents(cr,clock,ct_clock)
	cairo_move_to(cr,w/2-ct_clock.width/2,76)
	cairo_show_text(cr,clock)
	--Date
	cairo_set_font_size(cr, 18)
	ct_date = cairo_text_extents_t:create()
	cairo_text_extents(cr,date,ct_date)
	cairo_move_to(cr,w/2-ct_date.width/2,ct_clock.height+81)
	cairo_show_text(cr,date)
end

function draw_weather(cr, w, h)

	icon_id = conky_parse("${exec tail -n1 ~/.conky/conky-dashboard/.weather.txt}")
	icon = icons[icon_id]
	temp_c = conky_parse("${exec head -n1 ~/.conky/conky-dashboard/.weather.txt}")
	if tonumber(temp_c) ~= nil then
		temp_c = string.format("%.0f", temp_c)
	else
		temp_c = "N/A"
	end

	cairo_set_source_rgba(cr, r4, g4, b4, t)
	cairo_select_font_face (cr, "Font Awesome 5 Pro Light", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 92)
	ct_weather = cairo_text_extents_t:create()
	cairo_text_extents(cr,icon,ct_weather)
	cairo_move_to(cr,w/2+20,ct_weather.height/2+ct_clock.height+ct_date.height+136)
	cairo_show_text(cr,icon)
	--Temperature
	cairo_set_source_rgba(cr, r2, g2, b2, t)
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 52)
	ct_temperature = cairo_text_extents_t:create()
	cairo_text_extents(cr,temp_c .. "˚C",ct_temperature)
	cairo_move_to(cr,w/2-ct_temperature.width-20,ct_weather.height/2+ct_clock.height+ct_date.height-ct_temperature.height/2+142)
	cairo_show_text(cr,temp_c .. "˚C")
end

function draw_updates(cr, w, h)
	--Border
	cairo_set_line_width(cr, 1)
	cairo_set_source_rgba(cr, r3, g3, b3, t)
	cairo_move_to(cr,2,300)
	cairo_rel_line_to(cr,w-2,0)
    cairo_close_path(cr)
	cairo_stroke(cr)

	-- Get updates
	slackpkg = conky_parse("${exec grep Slackpkg ~/.conky/conky-dashboard/.updates.txt | cut -d \":\" -f 2 | xargs}")
	sbopkg = conky_parse("${exec grep Sbopkg ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	linux = conky_parse("${exec grep Linux ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	skype = conky_parse("${exec grep Skype ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	chrome = conky_parse("${exec grep Google-Chrome ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")
	nvidia = conky_parse("${exec grep Nvidia ~/.conky/conky-dashboard/.updates.txt | cut -d \":\"  -f 2 | xargs}")

	start_y = 380
	start_x = 120
	-- Updates
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_source_rgba(cr, r3, g3, b3, t)
	cairo_set_font_size(cr, 18)
	ct_updates = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Updates",ct_updates)
	cairo_move_to(cr,w/2-ct_updates.width/2,start_y)
	cairo_show_text(cr,"Updates")

	start_y = start_y + 35
	-- Slackpkg
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	r, g, b = hex2rgb(updates_text[slackpkg])
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_set_font_size(cr, 18)
	ct_slackpkg = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Slackpkg",ct_slackpkg)
	cairo_move_to(cr,w/2-start_x,start_y)
	cairo_show_text(cr,"Slackpkg")

	cairo_select_font_face (cr, "Font Awesome 5 Pro Solid", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 18)
	r, g, b = hex2rgb(updates_color[slackpkg])
	cairo_set_source_rgba(cr, r, g, b, t)
	ct_slackpkg_update = cairo_text_extents_t:create()
	cairo_text_extents(cr,updates[slackpkg],ct_slackpkg_update)
	cairo_move_to(cr,w/2+start_x,start_y)
	cairo_show_text(cr,updates[slackpkg])

	-- sbopkg
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	r, g, b = hex2rgb(updates_text[sbopkg])
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_set_font_size(cr, 18)
	ct_sbopkg = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Sbopkg",ct_sbopkg)
	cairo_move_to(cr,w/2-start_x,start_y+30)
	cairo_show_text(cr,"Sbopkg")

	cairo_select_font_face (cr, "Font Awesome 5 Pro Solid", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 18)
	r, g, b = hex2rgb(updates_color[sbopkg])
	cairo_set_source_rgba(cr, r, g, b, t)
	ct_sbopkg_update = cairo_text_extents_t:create()
	cairo_text_extents(cr,updates[sbopkg],ct_sbopkg_update)
	cairo_move_to(cr,w/2+start_x,start_y+30)
	cairo_show_text(cr,updates[sbopkg])

	-- Linux
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	r, g, b = hex2rgb(updates_text[linux])
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_set_font_size(cr, 18)
	ct_linux = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Linux",ct_linux)
	cairo_move_to(cr,w/2-start_x,start_y+60)
	cairo_show_text(cr,"Linux")

	cairo_select_font_face (cr, "Font Awesome 5 Pro Solid", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 18)
	r, g, b = hex2rgb(updates_color[linux])
	cairo_set_source_rgba(cr, r, g, b, t)
	ct_linux_update = cairo_text_extents_t:create()
	cairo_text_extents(cr,updates[linux],ct_linux_update)
	cairo_move_to(cr,w/2+start_x,start_y+60)
	cairo_show_text(cr,updates[linux])

	-- Chrome
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	r, g, b = hex2rgb(updates_text[chrome])
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_set_font_size(cr, 18)
	ct_chrome = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Chrome",ct_chrome)
	cairo_move_to(cr,w/2-start_x,start_y+90)
	cairo_show_text(cr,"Chrome")

	cairo_select_font_face (cr, "Font Awesome 5 Pro Solid", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 18)
	r, g, b = hex2rgb(updates_color[chrome])
	cairo_set_source_rgba(cr, r, g, b, t)
	ct_chrome_update = cairo_text_extents_t:create()
	cairo_text_extents(cr,updates[chrome],ct_chrome_update)
	cairo_move_to(cr,w/2+start_x,start_y+90)
	cairo_show_text(cr,updates[chrome])

	-- Skype
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	r, g, b = hex2rgb(updates_text[skype])
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_set_font_size(cr, 18)
	ct_skype = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Skype",ct_skype)
	cairo_move_to(cr,w/2-start_x,start_y+120)
	cairo_show_text(cr,"Skype")

	cairo_select_font_face (cr, "Font Awesome 5 Pro Solid", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 18)
	r, g, b = hex2rgb(updates_color[skype])
	cairo_set_source_rgba(cr, r, g, b, t)
	ct_skype_update = cairo_text_extents_t:create()
	cairo_text_extents(cr,updates[skype],ct_skype_update)
	cairo_move_to(cr,w/2+start_x,start_y+120)
	cairo_show_text(cr,updates[skype])

	-- Nvidia
	cairo_select_font_face (cr, "Overpass", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	r, g, b = hex2rgb(updates_text[nvidia])
	cairo_set_source_rgba(cr, r, g, b, t)
	cairo_set_font_size(cr, 18)
	ct_nvidia = cairo_text_extents_t:create()
	cairo_text_extents(cr,"Nvidia",ct_nvidia)
	cairo_move_to(cr,w/2-start_x,start_y+150)
	cairo_show_text(cr,"Nvidia")

	cairo_select_font_face (cr, "Font Awesome 5 Pro Solid", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 18)
	r, g, b = hex2rgb(updates_color[nvidia])
	cairo_set_source_rgba(cr, r, g, b, t)
	ct_nvidia_update = cairo_text_extents_t:create()
	cairo_text_extents(cr,updates[nvidia],ct_nvidia_update)
	cairo_move_to(cr,w/2+start_x,start_y+150)
	cairo_show_text(cr,updates[nvidia])
end

function draw_hdd(cr, w, h)

	start_y = 652
	cairo_select_font_face (cr, "Font Awesome 5 Pro Light", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 42)
	cairo_set_source_rgba(cr, r3, g3, b3, t)
	ct_hdd = cairo_text_extents_t:create()
	cairo_text_extents(cr, "", ct_hdd)
	cairo_move_to(cr,70,start_y + 15)
	cairo_show_text(cr,"")

    fs_used = math.floor(11*tonumber(conky_parse("${fs_used_perc " .. "/" .. "}"))/100)
    for i=0, 10 do
		cairo_set_source_rgba(cr, r3, g3, b3, t)
		cairo_arc(cr,140+20*i,start_y,6,0*math.pi/180,360*math.pi/180)
		cairo_fill(cr)
    end
    for i=0, fs_used do
		cairo_set_source_rgba(cr, r4, g4, b4, t)
		cairo_arc(cr,140+20*i,start_y,6,0*math.pi/180,360*math.pi/180)
		cairo_fill(cr)
	end

    -- Battery
	battery_percentage = math.floor(11*tonumber(conky_parse("${battery_percent}"))/100)
	battery_status = conky_parse("${battery_short}")
	battery_status = string.sub(battery_status,1,1)

	cairo_set_source_rgba(cr, r3, g3, b3, t)
	ct_hdd = cairo_text_extents_t:create()

	if battery_status == "C" or battery_status == "F" then
		cairo_text_extents(cr, "", ct_hdd)
		cairo_move_to(cr,70,start_y + 80 + 15)
		cairo_show_text(cr,"")
	elseif battery_status == "D" then
		cairo_text_extents(cr, "", ct_hdd)
		cairo_move_to(cr,70,start_y + 80 + 15)
		cairo_show_text(cr,"")
	end

    for i=0, 10 do
    	cairo_set_source_rgba(cr, r3, g3, b3, t)
    	cairo_arc(cr,140+20*i,start_y+80,6,0*math.pi/180,360*math.pi/180)
    	cairo_fill(cr)
    end
    for i=0, battery_percentage do
    	cairo_set_source_rgba(cr, r4, g4, b4, t)
    	cairo_arc(cr,140+20*i,start_y+80,6,0*math.pi/180,360*math.pi/180)
    	cairo_fill(cr)
    end
end
function draw_panel(cr, w, h)
    cairo_set_line_width(cr, 2)
    --Panel
	panel_background(cr, w, h)
	-- Panel border
	panel_border(cr, w, h)
    --Clock and date
	clock_and_date(cr, w, h)
	-- Weather
	draw_weather(cr, w, h)
	-- Updates
	draw_updates(cr, w, h)
    ---Hdd indicator
	draw_hdd(cr, w, h)
	--Indicators
end

function draw_widgets(cr)
	local w,h=conky_window.width,conky_window.height
	-- Api key
	api_key="13aad301dd37412e01c6c3d4abe0b12e"
	-- City
	city="Cluj-Napoca"
	-- Country code
	ccode="RO"
	-- Panel background
	color0="#20232C"
	-- Border background
	color1="#000000"
	-- Text colors
	color2="#A18673"
	-- Update border
	color3="#404047"
	-- Weather icon colors
	color4="#BE5C56"
	-- Other
	color5="#97B19C"

	r0, g0, b0 = hex2rgb(color0)
	r1, g1, b1 = hex2rgb(color1)
	r2, g2, b2 = hex2rgb(color2)
	r3, g3, b3 = hex2rgb(color3)
	r4, g4, b4 = hex2rgb(color4)
	r5, g5, b5 = hex2rgb(color5)

	-- Weather icons
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
	updates["No updates available"]=""
	updates["Updates available"]=""

	updates_color = {}
	updates_color["No updates available"]=color3
	updates_color["Updates available"]=color4

	updates_text = {}
	updates_text["No updates available"]=color3
	updates_text["Updates available"]=color2

	--Get coordinates of conky window and mouse
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