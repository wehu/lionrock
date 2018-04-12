def lionrock_deps():

    if "verilator" not in native.existing_rules():
        native.new_http_archive(
            name = "verilator",
            urls = ["https://github.com/wehu/lionrock/releases/download/v0.1/verilator-2018-03-18.tar.gz"],
            sha256 = "4a8f7151cbac8d705c8594680cec975e4b4d0fec59f0b98db8552158bbd57491",
            build_file = "@lionrock//:verilator.BUILD",
        )
   
    if "systemc" not in native.existing_rules(): 
        native.new_http_archive(
            name = "systemc",
            urls = ["https://github.com/wehu/lionrock/releases/download/v0.1/systemc-2.3.2.tar.gz"],
            sha256 = "16c0926d102ee56ad9687a81e45f6dfdd2cf34ec13d416f43faa545c49a9aaca",
            build_file = "@lionrock//:systemc.BUILD",
        )
        
    if "uvm_systemc" not in native.existing_rules():
        native.new_http_archive(
            name = "uvm_systemc",
            urls = ["https://github.com/wehu/lionrock/releases/download/v0.1/uvm-systemc-1.0-beta1.tar.gz"],
            sha256 = "6e31c8312b2a0abd82db746b615ea77956431e74270425d7d609368194253118",
            build_file = "@lionrock//:uvm-systemc.BUILD",
        )
        
    if "scv" not in native.existing_rules():
        native.new_http_archive(
            name = "scv",
            urls = ["https://github.com/wehu/lionrock/releases/download/v0.1/scv-2.0.1.tar.gz"],
            sha256 = "bd245b343da8e96e26c0b4d481640ee37701ce10d03e1b1b55f77e7bd9b5b765",
            build_file = "@lionrock//:scv.BUILD",
        )

