
public class floatConverter {
	public static final int MAN_MASK =0x007fffff;
	public static final int EXP_MASK=0x7f800000;
	
	public static int getExp(float f){
		int exp= Float.floatToIntBits(f);
		exp=exp&EXP_MASK;
		exp=exp>>>23;
		exp=exp-127;
		return exp;
	}
	
	public static int getMan(float f){
		int man = Float.floatToIntBits(f);
		man = man &MAN_MASK;
		man = man |0x00800000;
		return man;
	}
	
	public static void printMaxFloat(float f){
		int exp =getExp(f);
		int man = getMan(f)>>9;
		boolean negative = f<0;
		exp +=1;//in IEEE 745 the mantisa is 1.Man unsigned in max it is 0.1Man	
		
		if (!negative){
			System.out.printf("%h_",man);
		}
		else{ 
				man = ~man+1; //convert to 2's complement
				man  = man&0xffff; //take just the last 16 bits
				System.out.printf("%h_",man);
		}
		if (exp>0 &&exp<16)
			System.out.printf("0"); // add leading zero if exp is taking only one byte
		if (exp<0)
			exp=exp&0xff; //take just 8 bits
		System.out.printf("%h\n", exp);
	}
			
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		float f=(float)0.25;
		printMaxFloat(f);
		//	int X = getExp(f);
		//int M =getMan(f);
		//System.out.println( "exp= "+X);
		//System.out.println("man="+M);
	//	System.out.println(1/Math.sqrt(2));
	}

}
