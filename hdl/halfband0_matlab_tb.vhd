-- This testbench reads input data from text files that are generated from Steve's matlab data
-- and writes the results back out.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.mb_sync_pkg.all;

entity halfband0_matlab_tb is generic (data_width    : natural := 16); end entity halfband0_matlab_tb;

architecture rtl of halfband0_matlab_tb is

    signal reset      : std_logic;
    signal clk        : std_logic;
    signal dv_in      : std_logic;
    signal branch_in  : std_logic_vector(1 downto 0);
    signal real_in    : corr_array_t;
    signal imag_in    : corr_array_t;
    signal dv_out     : std_logic;
    signal real_out   : full_corr_array_t;
    signal imag_out   : full_corr_array_t;
    signal branch_out : std_logic_vector(1 downto 0);
    --
    constant clk_period  : time := 10 ns;
    signal endoffile : std_logic := '0';
    --constant inscale     : real := 2.0**(corr_dwidth-1);
    constant inscale     : real := 1.0;
begin

    stim_proc:process
        file   infile0       : text open read_mode is  "../../../../../../matlab/sb_out0.dat";
        file   infile1       : text open read_mode is  "../../../../../../matlab/sb_out1.dat";
        file   infile2       : text open read_mode is  "../../../../../../matlab/sb_out2.dat";
        file   infile3       : text open read_mode is  "../../../../../../matlab/sb_out3.dat";
        variable  inline    : line;
        variable  dataread1 : real;
    begin
        reset <= '1';
        dv_in <= '0';
        for i in 0 to Nsub-1 loop
            real_in(i) <= (others=>'X');
            imag_in(i) <= (others=>'X');
        end loop;
        branch_in <= "XX";
        wait for clk_period*4;

        reset <= '0';
        wait for clk_period*4;

        while (not endfile(infile3)) loop
            --
            dv_in <= '1';
            branch_in <= "00";
            for j in 0 to Nfft/2-1 loop
                readline(infile0, inline);
                for i in 0 to Nsub-1 loop
                    read(inline, dataread1);
                    real_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                    read(inline, dataread1);
                    imag_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                end loop;
                wait for clk_period*1;
            end loop;
            dv_in <= '0';
            branch_in <= "XX";
            wait for clk_period*2515;
            --
            dv_in <= '1';
            branch_in <= "01";
            for j in 0 to Nfft/2-1 loop
                readline(infile1, inline);
                for i in 0 to Nsub-1 loop
                    read(inline, dataread1);
                    real_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                    read(inline, dataread1);
                    imag_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                end loop;
                wait for clk_period*1;
            end loop;
            dv_in <= '0';
            branch_in <= "XX";
            wait for clk_period*2515;
            --
            dv_in <= '1';
            branch_in <= "10";
            for j in 0 to Nfft/2-1 loop
                readline(infile2, inline);
                for i in 0 to Nsub-1 loop
                    read(inline, dataread1);
                    real_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                    read(inline, dataread1);
                    imag_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                end loop;
                wait for clk_period*1;
            end loop;
            dv_in <= '0';
            branch_in <= "XX";
            wait for clk_period*2515;
            --
            dv_in <= '1';
            branch_in <= "11";
            for j in 0 to Nfft/2-1 loop
                readline(infile3, inline);
                for i in 0 to Nsub-1 loop
                    read(inline, dataread1);
                    real_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                    read(inline, dataread1);
                    imag_in(i) <= std_logic_vector(to_signed(integer(round(inscale*dataread1)), corr_dwidth));
                end loop;
                wait for clk_period*1;
            end loop;
            dv_in <= '0';
            branch_in <= "XX";
            wait for clk_period*2515;
            --
            dv_in <= '0';
            branch_in <= "XX";
            wait for clk_period*5812;
            --
        end loop;
        file_close(f=>infile0);
        file_close(f=>infile1);
        file_close(f=>infile2);
        file_close(f=>infile3);
        endoffile <= '1';
        wait for clk_period*Nfft*10; -- empty the pipe.

        assert false report "simulation ended" severity failure;
        wait;    

    end process;

    result_proc:process
        file res3_file : text open write_mode is "../../../corr_out3.dat";
        file res2_file : text open write_mode is "../../../corr_out2.dat";
        file res1_file : text open write_mode is "../../../corr_out1.dat";
        file res0_file : text open write_mode is "../../../corr_out0.dat";
        variable result_line : line;
    begin
        wait until rising_edge(clk);
        if (endoffile='0') and (dv_out='1') then
            for i in 0 to Nsub-1 loop
                write(L=>result_line, value=>to_integer(signed(real_out(0)(i))));
                write(L=>result_line, value=>string'("  "));
                write(L=>result_line, value=>to_integer(signed(imag_out(0)(i))));
                write(L=>result_line, value=>string'("  "));
            end loop;
            case branch_out is
                when "11" => writeline(res3_file, result_line);
                when "10" => writeline(res2_file, result_line);
                when "01" => writeline(res1_file, result_line);
                when "00" => writeline(res0_file, result_line);
                when others =>
            end case;
        end if;
    end process;
    

    uut: entity work.full_correlator 
    port map (
        reset         => reset      ,
        clk           => clk        ,
        --
        dv_in         => dv_in      ,
        real_in       => real_in    ,
        imag_in       => imag_in    ,
        branch_in     => branch_in  ,
        --
        dv_out        => dv_out     ,
        real_out      => real_out   ,
        imag_out      => imag_out   ,
        branch_out    => branch_out );


    clk_proc:process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;


end architecture rtl;


