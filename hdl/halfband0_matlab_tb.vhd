-- This testbench reads input data from text files that are generated from matlab data
-- and writes the results back out.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;

entity halfband0_matlab_tb is generic (data_width    : natural := 16); end entity halfband0_matlab_tb;

architecture rtl of halfband0_matlab_tb is
    --
    --COMPONENT halfband0
    --PORT (
        --aresetn : IN STD_LOGIC;
        --aclk : IN STD_LOGIC;
        --s_axis_data_tvalid : IN STD_LOGIC;
        --s_axis_data_tready : OUT STD_LOGIC;
        --s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        --m_axis_data_tvalid : OUT STD_LOGIC;
        --m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    --END COMPONENT;
    --
    signal aresetn            : std_logic;
    signal clk                : std_logic;
    signal s_axis_data_tvalid : STD_LOGIC;
    signal s_axis_data_tready : STD_LOGIC;
    signal s_axis_data_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal m_axis_data_tvalid : STD_LOGIC;
    signal m_axis_data_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --
    constant clk_period  : time := 10 ns;
    --
    signal real_in, imag_in  : std_logic_vector(11 downto 0);
    signal real_out, imag_out  : std_logic_vector(12 downto 0);
    --
begin

    stim_proc:process
        file  infile0      : text open read_mode is  "../../../../matlab/test_data.dat";
        variable inline    : line;
        variable dataread1 : integer;
    begin
        aresetn <= '0';
        real_in <= (others=>'X');
        imag_in <= (others=>'X');
        s_axis_data_tvalid  <= '0';
        wait for clk_period*4;

        aresetn <= '1';
        wait for clk_period*4;

        while (not endfile(infile0)) loop
            --
            s_axis_data_tvalid  <= '1';
            readline(infile0, inline);
            read(inline, dataread1);
            real_in <= std_logic_vector(to_signed(dataread1, 12));
            read(inline, dataread1);
            imag_in <= std_logic_vector(to_signed(dataread1, 12));
            wait for clk_period*1;

            s_axis_data_tvalid  <= '0';
            wait for clk_period*15;
            --
        end loop;
        file_close(f=>infile0);
        wait for clk_period*10;

        assert false report "simulation ended" severity failure;
        wait;    

    end process;

    result_proc:process
        file res0_file : text open write_mode is "../../../filt_out.dat";
        variable result_line : line;
    begin
        wait until rising_edge(clk);
        if (m_axis_data_tvalid='1') then
            write(L=>result_line, value=>to_integer(signed(real_out)));
            write(L=>result_line, value=>string'("  "));
            write(L=>result_line, value=>to_integer(signed(imag_out)));
            write(L=>result_line, value=>string'("  "));
            writeline(res0_file, result_line);
        end if;
    end process;

    -- Pack the axis data.
    s_axis_data_tdata(11 downto  0) <= real_in;
    s_axis_data_tdata(27 downto 16) <= imag_in;
    -- the core
    uut : entity work.halfband0
    PORT MAP (
        aresetn => aresetn,
        aclk => clk,
        s_axis_data_tvalid => s_axis_data_tvalid,
        s_axis_data_tready => s_axis_data_tready,
        s_axis_data_tdata => s_axis_data_tdata,
        m_axis_data_tvalid => m_axis_data_tvalid,
        m_axis_data_tdata => m_axis_data_tdata);
    -- rip the axis data
    real_out <= m_axis_data_tdata(12 downto  0);
    imag_out <= m_axis_data_tdata(28 downto 16);

    clk_proc:process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

end architecture rtl;


