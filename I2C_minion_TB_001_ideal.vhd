-----------------------------------------------------------------------------
-- Title      : I2C_minion Testbench
-----------------------------------------------------------------------------
-- File       : I2C_minion_TB_001_ideal
-- Author     : Peter Samarin <peter.samarin@gmail.com>
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------------------
entity I2C_minion_TB_001_ideal is
end I2C_minion_TB_001_ideal;
------------------------------------------------------------------------
architecture Testbench of I2C_minion_TB_001_ideal is
  constant T         : time    := 1000 ns;   -- clk period
  constant TH_I2C    : time    := 2500 ns;   -- i2c clk quarter period (100 kHz standard mode)
  constant T_MUL     : integer := 1;
  constant T_HALF    : integer := (TH_I2C * T_MUL * 2) / T;
  constant T_QUARTER : integer := (TH_I2C * T_MUL) / T;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal scl : std_logic := 'Z';
  signal sda : std_logic := 'Z';

  signal state_dbg      : integer                        := 0;
  signal received_data0 : std_logic_vector(7 downto 0)  := (others => '0');  -- MSB byte
  signal received_data1 : std_logic_vector(7 downto 0)  := (others => '0');  -- LSB byte
  signal received_datas : std_logic_vector(15 downto 0) := (others => '0');  -- full 16-bit word

  signal ack : std_logic := '0';

  -- 16-bit stimulus driven into Agrichip1_TX
  -- in2[15:8] = MSB byte,  in2[7:0] = LSB byte
  -- First value:  MSB=0x81 (10000001), LSB=0x7E (01111110)
  -- Second value: MSB=0x82 (10000010), LSB=0x7F (01111111)
  signal in2 : std_logic_vector(15 downto 0);

  -- simulation control
  shared variable ENDSIM : boolean := false;

begin

  ---- Design Under Verification -----------------------------------------
  DUV : entity work.Agrichip1_TX
    port map (
      bytes => in2,
      clk   => clk,
      arstn => rst,
      scl   => scl,
      sda   => sda
    );

  ---- Stimulus ----------------------------------------------------------
  in2 <= "1000000101111110", "1000001001111111" after 2 ms;

  ---- Clock running forever ---------------------------------------------
  process
  begin
    if ENDSIM = false then
      clk <= '0';
      wait for T/2;
      clk <= '1';
      wait for T/2;
    else
      wait;
    end if;
  end process;

  ---- Reset: active-low, released after half a clock period -------------
  rst <= '0', '1' after T/2;

  ----- Test vector generation -------------------------------------------
  TESTS : process is

    -- half clock
    procedure i2c_wait_half_clock is
    begin
      for i in 0 to T_HALF loop
        wait until rising_edge(clk);
      end loop;
    end procedure i2c_wait_half_clock;

    -- quarter clock
    procedure i2c_wait_quarter_clock is
    begin
      for i in 0 to T_QUARTER loop
        wait until rising_edge(clk);
      end loop;
    end procedure i2c_wait_quarter_clock;

    -- Write Bit
    procedure i2c_send_bit (constant a_bit : in std_logic) is
    begin
      scl <= '0';
      if a_bit = '0' then
        sda <= '0';
      else
        sda <= 'Z';
      end if;
      i2c_wait_quarter_clock;
      scl <= 'Z';
      i2c_wait_half_clock;
      scl <= '0';
      i2c_wait_quarter_clock;
    end procedure i2c_send_bit;

    -- Read Bit
    procedure i2c_receive_bit (variable a_bit : out std_logic) is
    begin
      scl <= '0';
      sda <= 'Z';
      i2c_wait_quarter_clock;
      scl <= 'Z';
      i2c_wait_quarter_clock;
      if sda = '0' then
        a_bit := '0';
      else
        a_bit := '1';
      end if;
      i2c_wait_quarter_clock;
      scl <= '0';
      i2c_wait_quarter_clock;
    end procedure i2c_receive_bit;

    -- Write Byte
    procedure i2c_send_byte (constant a_byte : in std_logic_vector(7 downto 0)) is
    begin
      for i in 7 downto 0 loop
        i2c_send_bit(a_byte(i));
      end loop;
    end procedure i2c_send_byte;

    -- Send 7-bit address
    procedure i2c_send_address (constant address : in std_logic_vector(6 downto 0)) is
    begin
      for i in 6 downto 0 loop
        i2c_send_bit(address(i));
      end loop;
    end procedure i2c_send_address;

    -- Read Byte
    procedure i2c_receive_byte (signal a_byte : out std_logic_vector(7 downto 0)) is
      variable a_bit : std_logic;
      variable accu  : std_logic_vector(7 downto 0) := (others => '0');
    begin
      for i in 7 downto 0 loop
        i2c_receive_bit(a_bit);
        accu(i) := a_bit;
      end loop;
      a_byte <= accu;
    end procedure i2c_receive_byte;

    -- START condition
    procedure i2c_start is
    begin
      scl <= 'Z';
      sda <= '0';
      i2c_wait_half_clock;
      scl <= 'Z';
      i2c_wait_quarter_clock;
      scl <= '0';
      i2c_wait_quarter_clock;
    end procedure i2c_start;

    -- STOP condition
    procedure i2c_stop is
    begin
      scl <= '0';
      sda <= '0';
      i2c_wait_quarter_clock;
      scl <= 'Z';
      i2c_wait_quarter_clock;
      sda <= 'Z';
      i2c_wait_half_clock;
      i2c_wait_half_clock;
    end procedure i2c_stop;

    -- Send read command bit
    procedure i2c_set_read is
    begin
      i2c_send_bit('1');
    end procedure i2c_set_read;

    -- Read ACK from slave
    procedure i2c_read_ack (signal ack : out std_logic) is
    begin
      scl <= '0';
      sda <= 'Z';
      i2c_wait_quarter_clock;
      scl <= 'Z';
      if sda = '0' then
        ack <= '1';
      else
        ack <= '0';
        assert false report "No ACK received: expected '0'" severity note;
      end if;
      i2c_wait_half_clock;
      scl <= '0';
      i2c_wait_quarter_clock;
    end procedure i2c_read_ack;

    -- Write NACK (master signals end of read)
    procedure i2c_write_nack is
    begin
      scl <= '0';
      sda <= 'Z';
      i2c_wait_quarter_clock;
      scl <= 'Z';
      i2c_wait_half_clock;
      scl <= '0';
      i2c_wait_quarter_clock;
    end procedure i2c_write_nack;

    -- Write ACK (master requests another byte)
    procedure i2c_write_ack is
    begin
      scl <= '0';
      sda <= '0';
      i2c_wait_quarter_clock;
      scl <= 'Z';
      i2c_wait_half_clock;
      scl <= '0';
      i2c_wait_quarter_clock;
    end procedure i2c_write_ack;

    -- ----------------------------------------------------------------
    -- Read 2 consecutive bytes from the slave (MSB first, then LSB).
    -- The slave latches the full 16-bit word on the first read request
    -- and selects the second byte automatically on the master ACK.
    --   data0 = MSB = in2[15:8]
    --   data1 = LSB = in2[7:0]
    -- ----------------------------------------------------------------
    procedure i2c_read_2bytes (
      constant address : in  std_logic_vector(6 downto 0);
      signal   data0   : out std_logic_vector(7 downto 0);
      signal   data1   : out std_logic_vector(7 downto 0)
    ) is
    begin
      state_dbg <= 0;
      i2c_start;
      state_dbg <= 1;
      i2c_send_address(address);
      state_dbg <= 2;
      i2c_set_read;
      state_dbg <= 3;
      i2c_read_ack(ack);
      if ack = '0' then
        state_dbg <= 9;
        i2c_stop;
        return;
      end if;
      ack <= '0';

      -- First byte: slave sends in2[15:8] (MSB)
      state_dbg <= 4;
      i2c_receive_byte(data0);
      state_dbg <= 5;
      i2c_write_ack;   -- ACK -> slave will load in2[7:0] next

      -- Second byte: slave sends in2[7:0] (LSB)
      state_dbg <= 6;
      i2c_receive_byte(data1);
      state_dbg <= 7;
      i2c_write_nack;  -- NACK -> end of transaction

      state_dbg <= 8;
      i2c_stop;
    end procedure i2c_read_2bytes;

  begin

    print("");
    print("------------------------------------------------------------");
    print("----------------- I2C_minion_TB_001_ideal ------------------");
    print("------------------------------------------------------------");

    scl <= 'Z';
    sda <= 'Z';

    -- *** FIX: wait for active-low reset to deassert, then add 10 clock
    -- cycles of margin so the slave FSM is guaranteed to reach idle
    -- before the first START condition appears on the bus.
    wait until rst = '1';
    for i in 0 to 9 loop
      wait until rising_edge(clk);
    end loop;

    print("---------- Testing repeated 2-byte reads (MSB first) -------");
    for i in 0 to 127 loop
      i2c_read_2bytes("0000011", received_data0, received_data1);

      -- Reassemble full 16-bit word: data0 is MSB, data1 is LSB
      received_datas <= received_data0 & received_data1;

      -- Assertions: uncomment to flag mismatches automatically
      -- assert (received_data0 & received_data1) = in2
      --   report "16-bit mismatch at iteration " & integer'image(i)
      --          & ": got " & to_hstring(received_data0 & received_data1)
      --          & " expected " & to_hstring(in2)
      --   severity warning;

      wait until rising_edge(clk);
    end loop;

    wait until rising_edge(clk);

    ENDSIM := true;
    print("Simulation end...");
    print("");
    wait;
  end process;
end Testbench;
