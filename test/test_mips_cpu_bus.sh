#!/bin/bash


SOURCE="$1"
INSTRUCTION="$2"  



if [[ -z ${INSTRUCTION} ]]; then

    TESTCASES="test/testcases/*.s"
    

    for i in ${TESTCASES} ; do
        TESTNAME=$(basename ${i} .s)

        >&2 echo "Test Bus CPU using test-case ${TESTNAME}"

        >&2 echo " 1 - Running assembler"

        python test/utils/assemble.py ${i} > test/bin/assembler_${TESTNAME}.txt 

        >&2 echo " 2 - Running reference simulator"

        python test/utils/run_simulator.py ${i} > test/reference/reference_${TESTNAME}.txt 

        >&2 echo " 3 - Compiling test-bench"

        iverilog -g 2012 \
        -s mips_cpu_bus_tb \
        -P mips_cpu_bus_tb.INSTR_INIT_FILE=\"test/bin/assembler_${TESTNAME}.txt\" \
        -o test/output/mips_cpu_bus_tb_${TESTNAME} \
        ${SOURCE}/*.v test/*.v

        >&2 echo " 4 - Running test-bench"

        ./test/output/mips_cpu_bus_tb_${TESTNAME} >null.stderr 


        >&2 echo "     Extracting value stored in register_v0"

        PATTERN="reg_v0 is:  "
        NOTHING=""
        grep "${PATTERN}" test/reference/reference_${TESTNAME}.txt > test/reference/reg_v0_${TESTNAME}.out-lines
        sed -e "s/${PATTERN}/${NOTHING}/g" test/reference/reg_v0_${TESTNAME}.out-lines > test/reference/reg_v0_${TESTNAME}.out

        >&2 echo "     Comparing register_v0 outputs"

        diff -w test/reference/reg_v0_${TESTNAME}.out test/cpu_output/tb_output.txt > null.stderr 
        RESULT=$?   

        INSTR=$(echo ${TESTNAME} | cut -d"-" -f1)   


        if [[ "${RESULT}" -ne 0 ]] ; then
        echo "  ${TESTNAME}, ${INSTR}, Fail"
        else
        echo "  ${TESTNAME}, ${INSTR}, Pass"
        fi

    done



else 

    TESTCASES="test/testcases/${INSTRUCTION}-*.s"
    
    if [[ -z ${TESTCASES} ]] ; then 
        exit 1
        
    else

        for i in ${TESTCASES} ; do
            TESTNAME=$(basename ${i} .s)
            
            >&2 echo "Test Bus CPU using test-case ${TESTNAME}"

            >&2 echo " 1 - Running assembler"

            python test/utils/assemble.py ${i} > test/bin/assembler_${TESTNAME}.txt 
            
            >&2 echo " 2 - Running reference simulator"

            python test/utils/run_simulator.py ${i} > test/reference/reference_${TESTNAME}.txt 
            
            >&2 echo " 3 - Compiling test-bench"

            iverilog -g 2012 \
            -s mips_cpu_bus_tb \
            -P mips_cpu_bus_tb.INSTR_INIT_FILE=\"test/bin/assembler_${TESTNAME}.txt\" \
            -o test/output/mips_cpu_bus_tb_${TESTNAME} \
            ${SOURCE}/*.v test/*.v
            
            
            >&2 echo " 4 - Running test-bench"

            ./test/output/mips_cpu_bus_tb_${TESTNAME} >null.stderr 
    
            >&2 echo "     Extracting value stored in register_v0"

            PATTERN="reg_v0 is:  "
            NOTHING=""
            grep "${PATTERN}" test/reference/reference_${TESTNAME}.txt > test/reference/reg_v0_${TESTNAME}.out-lines
            sed -e "s/${PATTERN}/${NOTHING}/g" test/reference/reg_v0_${TESTNAME}.out-lines > test/reference/reg_v0_${TESTNAME}.out

            >&2 echo "     Comparing register_v0 outputs"

            diff -w test/reference/reg_v0_${TESTNAME}.out test/cpu_output/tb_output.txt    > null.stderr 
            RESULT=$?   

            INSTR=$(echo ${TESTNAME} | cut -d"-" -f1)      


            if [[ "${RESULT}" -ne 0 ]] ; then
                echo "  ${TESTNAME}, ${INSTR}, Fail"
            else
                echo "  ${TESTNAME}, ${INSTR}, Pass"
            fi

        done


    fi



fi