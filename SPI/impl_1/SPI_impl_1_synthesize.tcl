if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/fonar/Documents/CS Remote/es4/SPI/SPI"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- SPI_impl_1.vm SPI_impl_1.ldc
run_engine_newmsg synthesis -f "SPI_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o SPI_impl_1_syn.udb SPI_impl_1.vm] "C:/Users/fonar/Documents/CS Remote/es4/SPI/SPI/impl_1/SPI_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
