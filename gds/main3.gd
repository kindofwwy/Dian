extends Node2D

@export var n=2000
@export var ran=3
@export var angv=0.001
@export var k=0.001
@export var zoomk=0.3
@export var t:Transform3D
@export var light=Vector3(-0.304367, -0.910224, -0.280959)
var formula_zoom=1
var formula_zoom_list=[1,1,1,1,1,1,3,2.3,1,1]
var a=1
var b=1
var c=1
var pos:Array[Vector3]
var colors:Array[Color]
var t2=turnt(angv,"y")
var ang=0
var funindex=0
var target_scale:Vector2
var colorindex=0
var colorsize=1
var target_pos:Array[Vector3]
var go_target=false
var go_target_k=0.01
var middle:Vector2
var cam_f=0.005
var target_cam_f=0.005
var cam_f_k=0.0001
var cam_dist=0

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	middle=get_viewport_rect().size/2
	position=middle
	target_scale=scale
	for i in range(n):
		pos.append(Vector3(randf_range(-ran,ran),randf_range(-ran,ran),randf_range(-ran,ran)))
		colors.append(Color(0,0,0))

func _process(delta):
	if go_target:
		for i in range(len(pos)):
			pos[i]+=go_target_k*(target_pos[i]-pos[i])
	else:
		for i in range(len(pos)):
			var p2=pos[i]*formula_zoom
			var f=formula(p2.x,p2.y,p2.z)
			var nx=k*2*f*dx(p2.x,p2.y,p2.z)
			var ny=k*2*f*dy(p2.x,p2.y,p2.z)
			var nz=k*2*f*dz(p2.x,p2.y,p2.z)
			pos[i].x-=clampf(nx,-0.5,0.5)
			pos[i].y-=clampf(ny,-0.5,0.5)
			pos[i].z-=clampf(nz,-0.5,0.5)
	t*=t2
	ang+=angv
	if ang>PI*2:
		ang-=PI*2
	scale+=zoomk*(target_scale-scale)
	queue_redraw()

func _draw():
	for i in range(len(pos)):
		var p=pos[i]
		var tp=t*p
		var c:Color
		if colorindex==0:
			var p2=p*colorsize/ran/2+Vector3(0.5,0.5,0.5)
			c=Color(p2.x,p2.y,p2.z)
		elif colorindex==1:
			var f=(formula(p.x*formula_zoom,p.y*formula_zoom,p.z*formula_zoom))**2
			f/=f+1
			f=-f+1
			c=Color(f,f,f)
		elif colorindex==2:
			var p2=Vector3(1,dx(tp.x,tp.y,tp.z),0).normalized().cross(Vector3(0,dz(tp.x,tp.y,tp.z),1).normalized())
			var f=p2.dot(light)
			var p3=Vector3(0,0,0.01).lerp(Vector3(0.99,0.97,0.91),f)
			c=Color(p3.x,p3.y,p3.z)
		colors[i]+=0.1*(c-colors[i])
		
		cam_f+=cam_f_k*(target_cam_f-cam_f)
		var size=max(0.01,abs(cam_dist-tp.z)*cam_f)
		var fade_color=Color(colors[i].r,colors[i].g,colors[i].b,(clamp(1/(size**2*1000),0,1)))
		draw_circle(Vector2(tp.x,tp.y),size,fade_color)
		#draw_circle(Vector2(tp.x,tp.y),0.01,colors[i])
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: # 鼠标按键事件
		if event.pressed: # 按下
			var target_pos = get_viewport().get_mouse_position()
			var p=Vector3((target_pos.x-middle.x)/scale.x,(target_pos.y-middle.y)/scale.y,randf_range(-ran/2,ran/2))*turnt(ang,"y")
			pos.append(p)
			colors.append(Color(0,0,0))
				
	elif event.is_action("quit"):
		get_tree().quit()
	elif event.is_action_pressed("go_random"):
		target_pos.clear()
		for i in range(len(pos)):
			target_pos.append(Vector3(randf_range(-ran,ran),randf_range(-ran,ran),randf_range(-ran,ran)))
		go_target=true
	elif event.is_action_pressed("formula1"):
		funindex=1
		go_target=false
	elif event.is_action_pressed("formula2"):
		funindex=2
		go_target=false
	elif event.is_action_pressed("formula3"):
		funindex=3
		go_target=false
	elif event.is_action_pressed("formula4"):
		funindex=4
		go_target=false
	elif event.is_action_pressed("formula5"):
		funindex=5
		go_target=false
	elif event.is_action_pressed("formula6"):
		funindex=6
		go_target=false
	elif event.is_action_pressed("formula7"):
		funindex=7
		go_target=false
	elif event.is_action_pressed("formula8"):
		funindex=8
		go_target=false
	elif event.is_action_pressed("next_color"):
		colorindex+=1
		colorindex%=3
	elif event.is_action_pressed("zoom_up",true):
		target_scale*=1.1
	elif event.is_action_pressed("zoom_down",true):
		target_scale*=0.909
	elif event.is_action_pressed("color_right",true):
		if colorindex==0:
			colorsize*=1.1
		elif colorindex==2:
			light*=turnt(-0.05,"z")
	elif event.is_action_pressed("color_left",true):
		if colorindex==0:
			colorsize*=0.909
		elif colorindex==2:
			light*=turnt(0.05,"z")
	elif event.is_action_pressed("color_up",true):
		light*=turnt(-0.05,"x")
	elif event.is_action_pressed("color_down",true):
		light*=turnt(0.05,"x")
	elif  event.is_action_pressed("formula_zoom_up",true):
		formula_zoom_list[funindex-1]*=0.95
	elif event.is_action_pressed("formula_zoom_down",true):
		formula_zoom_list[funindex-1]*=1.05
	elif event.is_action_pressed("cam_f_up",true):
		target_cam_f*=1.1
	elif event.is_action_pressed("cam_f_down",true):
		target_cam_f*=0.909
	elif event.is_action_pressed("cam_dist_up",true):
		cam_dist+=0.03
	elif event.is_action_pressed("cam_dist_down",true):
		cam_dist-=0.03
	formula_zoom=formula_zoom_list[funindex-1]

func formula(x,y,z,index=funindex):
	if index==1:
		return (x*x)/a+(z*z)/c-(y*y)/b+1
	if index==2:
		return x*sin(y)+y*sin(z)+z*sin(x)-1
	if index==3:
		return (x*x)/a+(z*z)/c+(y*y)/b-ran
	if index==4:
		return sin(2*x*x+2*y*y)-z
	if index==5:
		return sin(x*2)+sin(z*2)-y*2
	if index==6:
		return x*y*z
	if index==7:
		return sin(x)+sin(y)+sin(z)
	if index==8:
		return sin(x)**2+sin(y)**2+sin(z)**2#sin(x)*sin(y)*sin(z)
	return 0

func dx(x,y,z,index=funindex):
	if index==1:
		return 2/a*x
	if index==2:
		return sin(y)+z*cos(x)
	if index==3:
		return 2/a*x
	if index==4:
		return cos(2*x*x+2*y*y)*2*x*2
	if index==5:
		return cos(x*2)*2
	if index==6:
		return y*z
	if index==7:
		return cos(x)
	if index==8:
		return 2*sin(x)*cos(x)#sin(y)*sin(z)*cos(x)
	return 0

func dy(x,y,z,index=funindex):
	if index==1:
		return -2/b*y
	if index==2:
		return sin(z)+x*cos(y)
	if index==3:
		return 2/b*y
	if index==4:
		return cos(2*x*x+2*y*y)*2*y*2
	if index==5:
		return -2
	if index==6:
		return x*z
	if index==7:
		return cos(y)
	if index==8:
		return 2*sin(y)*cos(y)#sin(x)*sin(z)*cos(y)
	return 0

func dz(x,y,z,index=funindex):
	if index==1:
		return 2/c*z
	if index==2:
		return sin(x)+y*cos(z)
	if index==3:
		return 2/c*z
	if index==4:
		return -1
	if index==5:
		return cos(z*2)*2
	if index==6:
		return x*y
	if index==7:
		return cos(z)
	if index==8:
		return 2*sin(z)*cos(z)#sin(y)*sin(x)*cos(z)
	return 0

func turnt(angle,axis):
	if axis=="x":
		return Transform3D(Vector3(1,0,0),Vector3(0,cos(angle),-sin(angle)),Vector3(0,sin(angle),cos(angle)),Vector3(0,0,0))
	if axis=="y":
		return Transform3D(Vector3(cos(angle),0,sin(angle)),Vector3(0,1,0),Vector3(-sin(angle),0,cos(angle)),Vector3(0,0,0))
	if axis=="z":
		return Transform3D(Vector3(cos(angle),sin(angle),0),Vector3(-sin(angle),cos(angle),0),Vector3(0,0,1),Vector3(0,0,0))

