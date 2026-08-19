
########################### Define Top Module ############################
                                                   
set top_module Processor_TopLevel

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

################## Design Compiler Library Files #setup ######################
set_svf Processor_TopLevel.svf


lappend search_path /home/IC/micro_project/syn
lappend search_path /home/IC/micro_project/rtl

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

#echo "###############################################"
#echo "############# Reading RTL Files  ##############"
#echo "###############################################"
set file_format verilog


#Processor_TopLevel Files


read_file -format $file_format ALU.v
read_file -format $file_format CCR.v
read_file -format $file_format Control_Unit.v
read_file -format $file_format decode_wb_stage.v
read_file -format $file_format Execute_stage.v
read_file -format $file_format EX_M_register.v
read_file -format $file_format FetchStage.v
read_file -format $file_format Forwarding_unit.v
read_file -format $file_format hazard_detection_unit.v
read_file -format $file_format ID_EX_register.v
read_file -format $file_format IF_ID_reg.v
read_file -format $file_format Instruction_Memory.v
read_file -format $file_format MemoryStage.v
read_file -format $file_format MEM_WB_Register.v
read_file -format $file_format Program_Counter.v
read_file -format $file_format Register_File.v
read_file -format $file_format top.v


###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design

############################### Path groups ################################
puts "###############################################"
puts "################ Path groups ##################"
puts "###############################################"

group_path -name INREG -from [all_inputs]
group_path -name REGOUT -to [all_outputs]
group_path -name INOUT -from [all_inputs] -to [all_outputs]

#################### Define Design Constraints #########################
puts "###############################################"
puts "############ Design Constraints #### ##########"
puts "###############################################"

source -echo ./cons.tcl

###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"

compile -map_effort high

set_svf -off

#############################################################################
# Write out Design after initial compile
#############################################################################
write_file -format verilog -hierarchy -output Processor_TopLevel.v
write_file -format ddc     -hierarchy -output Processor_TopLevel.ddc
write_sdc  -nosplit Processor_TopLevel.sdc
write_sdf           Processor_TopLevel.sdf

################# reporting #######################

report_power -hierarchy > power.rpt
report_area -hierarchy > area.rpt
report_timing -max_paths 100 -delay_type max > setup.rpt
report_timing -max_paths 100 -delay_type min > hold.rpt
report_clock -attributes > clocks.rpt
report_constraint -all_violators > constraints.rpt

################# starting graphical user interface #######################

gui_start
