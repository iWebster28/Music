# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog ChordMachine2Model.v

#load simulation using mux as the top level simulation module
vsim shiftReg4bit

#CAN LIST THE OTHER MODULES TO SIMULATE HERE TOO

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#Clock
force {clk} 0 0ns, 1 {5ns} -r 10ns
force {BPMShiftEn} 0 0ns, 1 {100ns} -r 100ns
#24999999ns

#REMEMBER - KEY[0] IS NOT INVERTED - therefore 1 = 1, 0 = 0 - the rest of the keys are active low within the FSM (0 to activate in modelsim)

#Case 1 - load x, hit KEY[3], load y, hit KEY[1] - expect output from VGA module - simulate separately
#Data inputs
#KEY[0] = active low resetn (resets FMS and registers - does not clear screen)
#KEY[1] = Plot
#KEY[2] = set blank screen
#KEY[3] = loads register with x value (loaded from switches 6:0)
#SW[9:7] = colour
#SW[6:0] = input x,y

#D, clk, loopEn, BPMShiftEn, Q, key, trackLEDIn, Qstatic

force {D[3:0]} 1000
force {loopEn} 0
force {key} 0
run 20ns

force {loopEn} 1
force {key} 1
run 20ns

force {key} 0
run 1000ns



