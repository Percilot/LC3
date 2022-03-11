#include<stdio.h>
#include<string.h>
#define SPACE 0x10000

//全局变量定义区，为了方便函数的访问，将寄存器和内存都设置为全局变量。
//同时由于不需要判断ACV的情况，所以没有设置PSR寄存器，而是直接使用N，Z，P更加方便
short int Regs[8];
unsigned short int PC=0;
short int N,Z,P;
unsigned short int memory[SPACE];

//本函数的意义是，将以指定位数的二进制字符串形式转换为无符号整数
unsigned short int change(char a[],int count)
{
    short int i,result;
    for(i=0,result=0;i<count;i++)
    {
        //只接受字符0，1作为有效数据，其他数据认为是错误输入而结束本函数
        if(a[i]=='0'||a[i]=='1')
            result=2*result+a[i]-'0';
        else 
            break;
    }
    return result;
}

//本函数的意义是，执行加法
void ADD(unsigned short int instruction)
{
    unsigned short int rd,rs1,rs2;
    int sign,immsign,imm;

    //计算源1寄存器和目标寄存器地址
    rd=(unsigned short int)(instruction&0x0E00)>>9;
    rs1=(unsigned short int)(instruction&0x01C0)>>6;
    //通过sign判断是寄存器间加法还是寄存器加立即数
    sign=(int)(instruction&0x0020);

    if(sign==0)
    {
        //寄存器间加法的运行
        rs2=(unsigned short int)(instruction&0x0007);
        Regs[rd]=(short int)(Regs[rs1]+Regs[rs2]);
    }
    else
    {
        //求二进制补码表示的立即数的值
        immsign=(int)(instruction&0x0010);
        if(immsign==0)
            imm=(int)(instruction&0x001F);
        else
            imm=(int)(-(((instruction^0x001F)&0x001F)+1));

        //寄存器与立即数加法的运行
        Regs[rd]=(short int)(Regs[rs1]+imm);
    }

    //设置N，Z，P
    if(Regs[rd]>0)
    {
        P=1;
        N=Z=0;
    }
    else if(Regs[rd]==0)
    {
        Z=1;
        N=P=0;
    }
    else
    {
        N=1;
        P=Z=0;
    }
    return;
}

void AND(unsigned short int instruction)
{
    unsigned short int rd,rs1,rs2;
    int sign,immsign,imm;

    rd=(unsigned short int)(instruction&0x0E00)>>9;
    rs1=(unsigned short int)(instruction&0x01C0)>>6;
    rs2=(unsigned short int)(instruction&0x0007);
    sign=(int)(instruction&0x0020);

    if(sign==0)
        Regs[rd]=(short int)(Regs[rs1]&Regs[rs2]);
    else
    {
        immsign=(int)(instruction&0x0010);
        if(immsign==0)
            imm=(int)(instruction&0x001F);
        else
            imm=(int)(-(((instruction^0x001F)&0x001F)+1));
        
        Regs[rd]=(short int)(Regs[rs1]&imm);
    }

    if(Regs[rd]>0)
    {
        P=1;
        N=Z=0;
    }
    else if(Regs[rd]==0)
    {
        Z=1;
        N=P=0;
    }
    else
    {
        N=1;
        P=Z=0;
    }
    return;
}

void NOT(unsigned short int instruction)
{
    unsigned short int rd,rs;

    rd=(unsigned short int)(instruction&0x0E00)>>9;
    rs=(unsigned short int)(instruction&0x01C0)>>6;

    Regs[rd]=(short int)(~Regs[rs]);

    if(Regs[rd]>0)
    {
        P=1;
        N=Z=0;
    }
    else if(Regs[rd]==0)
    {
        Z=1;
        N=P=0;
    }
    else
    {
        N=1;
        P=Z=0;
    }
    return;
}

void LD(unsigned short int instruction)
{
    unsigned short int rd;
    int offset,OffsetSign;
    rd=(unsigned short int)(instruction&0x0E00)>>9;
    OffsetSign=(int)(instruction&0x0100);
    if(OffsetSign==0)
        offset=(int)(instruction&0x01FF);
    else
        offset=(int)(-(((instruction^0x01FF)&0x01FF)+1));
    Regs[rd]=(short int)(memory[(unsigned short int)(PC+offset)]);
    if(Regs[rd]>0)
    {
        P=1;
        N=Z=0;
    }
    else if(Regs[rd]==0)
    {
        Z=1;
        N=P=0;
    }
    else
    {
        N=1;
        P=Z=0;
    }
    return;
}

void LDI(unsigned short int instruction)
{
    unsigned short int rd;
    int offset,OffsetSign;
    rd=(unsigned short int)(instruction&0x0E00)>>9;
    OffsetSign=(int)(instruction&0x0100);
    if(OffsetSign==0)
        offset=(int)(instruction&0x01FF);
    else
        offset=(int)(-(((instruction^0x01FF)&0x01FF)+1));

    Regs[rd]=(short int)(memory[(unsigned short int)(memory[(unsigned short int)(PC+offset)])]);

    if(Regs[rd]>0)
    {
        P=1;
        N=Z=0;
    }
    else if(Regs[rd]==0)
    {
        Z=1;
        N=P=0;
    }
    else
    {
        N=1;
        P=Z=0;
    }
    return;
}

void LDR(unsigned short int instruction)
{
    unsigned short int rd,rs;
    int offset,OffsetSign;
    rd=(unsigned short int)(instruction&0x0E00)>>9;
    rs=(unsigned short int)(instruction&0x01C0)>>6;
    OffsetSign=(int)(instruction&0x0020);
    if(OffsetSign==0)
        offset=(int)(instruction&0x003F);
    else
        offset=(int)(-(((instruction^0x003F)&0x003F)+1));

    Regs[rd]=(short int)(memory[(unsigned short int)(Regs[rs]+offset)]);

    if(Regs[rd]>0)
    {
        P=1;
        N=Z=0;
    }
    else if(Regs[rd]==0)
    {
        Z=1;
        N=P=0;
    }
    else
    {
        N=1;
        P=Z=0;
    }
    return;
}

void LEA(unsigned short int instruction)
{
    unsigned short int rd;
    int offset,OffsetSign;
    rd=(unsigned short int)(instruction&0x0E00)>>9;
    OffsetSign=(int)(instruction&0x0100);
    if(OffsetSign==0)
        offset=(int)(instruction&0x01FF);
    else
        offset=(int)(-(((instruction^0x01FF)&0x01FF)+1));

    Regs[rd]=(short int)(PC+offset);

    return;
}

void ST(unsigned short int instruction)
{
    unsigned short int rs;
    int offset,OffsetSign;
    rs=(unsigned short int)(instruction&0x0E00)>>9;
    OffsetSign=(int)(instruction&0x0100);
    if(OffsetSign==0)
        offset=(int)(instruction&0x01FF);
    else
        offset=(int)(-(((instruction^0x01FF)&0x01FF)+1));

    memory[(unsigned short int)(PC+offset)]=(unsigned short int)Regs[rs];

    return;
}

void STI(unsigned short int instruction)
{
    unsigned short int rs;
    int offset,OffsetSign;
    rs=(unsigned short int)(instruction&0x0E00)>>9;
    OffsetSign=(int)(instruction&0x0100);
    if(OffsetSign==0)
        offset=(int)(instruction&0x01FF);
    else
        offset=(int)(-(((instruction^0x01FF)&0x01FF)+1));

    memory[(unsigned short int)(memory[(unsigned short int)(PC+offset)])]=(unsigned short int)Regs[rs];

    return;
}

void STR(unsigned short int instruction)
{
    unsigned short int rd,rs;
    int offset,OffsetSign;
    rd=(unsigned short int)(instruction&0x0E00)>>9;
    rs=(unsigned short int)(instruction&0x01C0)>>6;
    OffsetSign=(int)(instruction&0x0020);
    if(OffsetSign==0)
        offset=(int)(instruction&0x003F);
    else
        offset=(int)(-(((instruction^0x003F)&0x003F)+1));

    memory[(unsigned short int)(Regs[rs]+offset)]=(unsigned short int)Regs[rd];

    return;
}

void BR(unsigned short int instruction)
{
    short int n,z,p;
    int sign;
    int offset,OffsetSign;
    n=(unsigned short int)(instruction&0x0800)>>11;
    z=(unsigned short int)(instruction&0x0400)>>10;
    p=(unsigned short int)(instruction&0x0200)>>9;
    sign=(n&N)|(z&Z)|(p&P);
    //printf("%d\n",sign);
    if(sign!=0)
    {
        OffsetSign=(int)(instruction&0x0100);
        if(OffsetSign==0)
            offset=(int)(instruction&0x01FF);
        else
            offset=(int)(-(((instruction^0x01FF)&0x01FF)+1));
        PC=(unsigned short int)(PC+offset);
    }
    return;
}

void JMP(unsigned short int instruction)
{
    unsigned short int rs;
    rs=(unsigned short int)(instruction&0x01C0)>>6;
    PC=Regs[rs];
    return;
}

void JSRorJSRR(unsigned short int instruction)
{
    unsigned short int rs;
    int sign;
    int offset,OffsetSign;
    sign=(unsigned short int)(instruction&0x0800)>>11;
    Regs[7]=PC;
    if(sign!=0)
    {
        OffsetSign=(instruction&0x0400);
        if(OffsetSign==0)
            offset=instruction&0x07FF;
        else
            offset=-(((instruction^0x07FF)&0x07FF)+1);
        PC=(unsigned short int)(PC+offset);
    }
    else
    {
        rs=(unsigned short int)(instruction&0x01C0)>>6;
        PC=(unsigned short int)Regs[rs];
    }
    return;
}

int main()
{
    int i;
    unsigned short int address;
    unsigned short int StartAddress;
    short int sign;
    unsigned short int opcode;
    unsigned short int instruction;
    char inst[30];
    Z=1;
    P=N=0;
    memset(memory,0x7777,SPACE*sizeof(short int));
    memset(Regs,0x7777,8*sizeof(short int));
    scanf("%s",inst);
    address=change(inst,16);
    StartAddress=address;
    for(;;address++)
    {
        sign=scanf("%s",inst);
        if(sign==EOF)
            break;
        memory[address]=(unsigned short int)change(inst,16);
    }
    PC=StartAddress;
    while(1)
    {
        instruction=memory[PC];
        PC++;
        if(instruction==0xF025)
            break;
        opcode=(unsigned short int)(instruction&0xF000)>>12;
        switch(opcode)
        {
            case 0:BR(instruction);break;
            case 1:ADD(instruction);break;
            case 2:LD(instruction);break;
            case 3:ST(instruction);break;
            case 4:JSRorJSRR(instruction);break;
            case 5:AND(instruction);break;
            case 6:LDR(instruction);break;
            case 7:STR(instruction);break;
            case 9:NOT(instruction);break;
            case 10:LDI(instruction);break;
            case 11:STI(instruction);break;
            case 12:JMP(instruction);break;
            case 14:LEA(instruction);break;
            default:break;
        }
    }
    
    for(i=0;i<8;i++)
        printf("R%d = x%04hX\n",i,Regs[i]);

    return 0;
}