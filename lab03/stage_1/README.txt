����CPU������ʦ�Ͽθ����Ŀ�ܡ�


��Ҫ��
    �弶��ˮ��
    ������ʽ����������أ�
    ֧��ָ�LUI��ADDU��ADDIU��BEQ��BNE��LW��OR��SLT��SLTI��SLTIU��SLL��SW��J��JAL��JR��
    �ϰ�ͨ����


������֯��
mycpu_top.v

----nextpc_gen.v        #����߼���Ϊfetch_stage�ṩnextpc
----fetch_stage.v       #ȡ�뼶����ָ��洢����ȡָ����

----decode_stage.v      #���뼶������ָ����������źš��ж���ת
--------alu.v           #���������ж�

----execute_stage.v     #ִ�м�������߼�����
--------alu.v
----memory_stage.v      #�洢������д���ݴ洢��
----writeback_stage.v   #д�ؼ��������д��Ĵ���

----regfile_2r1w.v      #ͬ��д�첽���Ĵ�����