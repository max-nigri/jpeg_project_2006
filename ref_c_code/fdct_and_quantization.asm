.globl _fdct_and_quantization
	.def	_fdct_and_quantization;	.scl	2;	.type	32;	.endef
_fdct_and_quantization:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$360, %esp
	movb	$0, -350(%ebp)
L120:
	cmpb	$63, -350(%ebp)
	ja	L121
	movzbl	-350(%ebp), %ecx
	movzbl	-350(%ebp), %edx
	movl	8(%ebp), %eax
	movsbw	(%eax,%edx),%ax
	pushw	%ax
	filds	(%esp)
	leal	2(%esp), %esp
	fstps	-344(%ebp,%ecx,4)
	leal	-350(%ebp), %eax
	incb	(%eax)
	jmp	L120
L121:
	leal	-344(%ebp), %eax
	movl	%eax, -88(%ebp)
	movb	$7, -349(%ebp)
L123:
	cmpb	$0, -349(%ebp)
	js	L124
	movl	-88(%ebp), %eax
	movl	-88(%ebp), %edx
	addl	$28, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-12(%ebp)
	movl	-88(%ebp), %eax
	movl	-88(%ebp), %edx
	addl	$28, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-40(%ebp)
	movl	-88(%ebp), %eax
	addl	$4, %eax
	movl	-88(%ebp), %edx
	addl	$24, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-16(%ebp)
	movl	-88(%ebp), %eax
	addl	$4, %eax
	movl	-88(%ebp), %edx
	addl	$24, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-36(%ebp)
	movl	-88(%ebp), %eax
	addl	$8, %eax
	movl	-88(%ebp), %edx
	addl	$20, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-20(%ebp)
	movl	-88(%ebp), %eax
	addl	$8, %eax
	movl	-88(%ebp), %edx
	addl	$20, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-32(%ebp)
	movl	-88(%ebp), %eax
	addl	$12, %eax
	movl	-88(%ebp), %edx
	addl	$16, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-24(%ebp)
	movl	-88(%ebp), %eax
	addl	$12, %eax
	movl	-88(%ebp), %edx
	addl	$16, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-28(%ebp)
	flds	-12(%ebp)
	fadds	-24(%ebp)
	fstps	-44(%ebp)
	flds	-12(%ebp)
	fsubs	-24(%ebp)
	fstps	-56(%ebp)
	flds	-16(%ebp)
	fadds	-20(%ebp)
	fstps	-48(%ebp)
	flds	-16(%ebp)
	fsubs	-20(%ebp)
	fstps	-52(%ebp)
	movl	-88(%ebp), %eax
	flds	-44(%ebp)
	fadds	-48(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$16, %eax
	flds	-44(%ebp)
	fsubs	-48(%ebp)
	fstps	(%eax)
	flds	-52(%ebp)
	fadds	-56(%ebp)
	flds	LC6
	fmulp	%st, %st(1)
	fstps	-60(%ebp)
	movl	-88(%ebp), %eax
	addl	$8, %eax
	flds	-56(%ebp)
	fadds	-60(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$24, %eax
	flds	-56(%ebp)
	fsubs	-60(%ebp)
	fstps	(%eax)
	flds	-28(%ebp)
	fadds	-32(%ebp)
	fstps	-44(%ebp)
	flds	-32(%ebp)
	fadds	-36(%ebp)
	fstps	-48(%ebp)
	flds	-36(%ebp)
	fadds	-40(%ebp)
	fstps	-52(%ebp)
	flds	-44(%ebp)
	fsubs	-52(%ebp)
	flds	LC7
	fmulp	%st, %st(1)
	fstps	-76(%ebp)
	flds	-44(%ebp)
	flds	LC8
	fmulp	%st, %st(1)
	fadds	-76(%ebp)
	fstps	-64(%ebp)
	flds	-52(%ebp)
	flds	LC9
	fmulp	%st, %st(1)
	fadds	-76(%ebp)
	fstps	-72(%ebp)
	flds	-48(%ebp)
	flds	LC6
	fmulp	%st, %st(1)
	fstps	-68(%ebp)
	flds	-40(%ebp)
	fadds	-68(%ebp)
	fstps	-80(%ebp)
	flds	-40(%ebp)
	fsubs	-68(%ebp)
	fstps	-84(%ebp)
	movl	-88(%ebp), %eax
	addl	$20, %eax
	flds	-84(%ebp)
	fadds	-64(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$12, %eax
	flds	-84(%ebp)
	fsubs	-64(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$4, %eax
	flds	-80(%ebp)
	fadds	-72(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$28, %eax
	flds	-80(%ebp)
	fsubs	-72(%ebp)
	fstps	(%eax)
	leal	-88(%ebp), %eax
	addl	$32, (%eax)
	leal	-349(%ebp), %eax
	decb	(%eax)
	jmp	L123
L124:
	leal	-344(%ebp), %eax
	movl	%eax, -88(%ebp)
	movb	$7, -349(%ebp)
L126:
	cmpb	$0, -349(%ebp)
	js	L127
	movl	-88(%ebp), %eax
	movl	-88(%ebp), %edx
	addl	$224, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-12(%ebp)
	movl	-88(%ebp), %eax
	movl	-88(%ebp), %edx
	addl	$224, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-40(%ebp)
	movl	-88(%ebp), %eax
	addl	$32, %eax
	movl	-88(%ebp), %edx
	addl	$192, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-16(%ebp)
	movl	-88(%ebp), %eax
	addl	$32, %eax
	movl	-88(%ebp), %edx
	addl	$192, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-36(%ebp)
	movl	-88(%ebp), %eax
	addl	$64, %eax
	movl	-88(%ebp), %edx
	addl	$160, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-20(%ebp)
	movl	-88(%ebp), %eax
	addl	$64, %eax
	movl	-88(%ebp), %edx
	addl	$160, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-32(%ebp)
	movl	-88(%ebp), %eax
	addl	$96, %eax
	movl	-88(%ebp), %edx
	subl	$-128, %edx
	flds	(%eax)
	fadds	(%edx)
	fstps	-24(%ebp)
	movl	-88(%ebp), %eax
	addl	$96, %eax
	movl	-88(%ebp), %edx
	subl	$-128, %edx
	flds	(%eax)
	fsubs	(%edx)
	fstps	-28(%ebp)
	flds	-12(%ebp)
	fadds	-24(%ebp)
	fstps	-44(%ebp)
	flds	-12(%ebp)
	fsubs	-24(%ebp)
	fstps	-56(%ebp)
	flds	-16(%ebp)
	fadds	-20(%ebp)
	fstps	-48(%ebp)
	flds	-16(%ebp)
	fsubs	-20(%ebp)
	fstps	-52(%ebp)
	movl	-88(%ebp), %eax
	flds	-44(%ebp)
	fadds	-48(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	subl	$-128, %eax
	flds	-44(%ebp)
	fsubs	-48(%ebp)
	fstps	(%eax)
	flds	-52(%ebp)
	fadds	-56(%ebp)
	flds	LC6
	fmulp	%st, %st(1)
	fstps	-60(%ebp)
	movl	-88(%ebp), %eax
	addl	$64, %eax
	flds	-56(%ebp)
	fadds	-60(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$192, %eax
	flds	-56(%ebp)
	fsubs	-60(%ebp)
	fstps	(%eax)
	flds	-28(%ebp)
	fadds	-32(%ebp)
	fstps	-44(%ebp)
	flds	-32(%ebp)
	fadds	-36(%ebp)
	fstps	-48(%ebp)
	flds	-36(%ebp)
	fadds	-40(%ebp)
	fstps	-52(%ebp)
	flds	-44(%ebp)
	fsubs	-52(%ebp)
	flds	LC7
	fmulp	%st, %st(1)
	fstps	-76(%ebp)
	flds	-44(%ebp)
	flds	LC8
	fmulp	%st, %st(1)
	fadds	-76(%ebp)
	fstps	-64(%ebp)
	flds	-52(%ebp)
	flds	LC9
	fmulp	%st, %st(1)
	fadds	-76(%ebp)
	fstps	-72(%ebp)
	flds	-48(%ebp)
	flds	LC6
	fmulp	%st, %st(1)
	fstps	-68(%ebp)
	flds	-40(%ebp)
	fadds	-68(%ebp)
	fstps	-80(%ebp)
	flds	-40(%ebp)
	fsubs	-68(%ebp)
	fstps	-84(%ebp)
	movl	-88(%ebp), %eax
	addl	$160, %eax
	flds	-84(%ebp)
	fadds	-64(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$96, %eax
	flds	-84(%ebp)
	fsubs	-64(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$32, %eax
	flds	-80(%ebp)
	fadds	-72(%ebp)
	fstps	(%eax)
	movl	-88(%ebp), %eax
	addl	$224, %eax
	flds	-80(%ebp)
	fsubs	-72(%ebp)
	fstps	(%eax)
	leal	-88(%ebp), %eax
	addl	$4, (%eax)
	leal	-349(%ebp), %eax
	decb	(%eax)
	jmp	L126
L127:
	movb	$0, -350(%ebp)
L129:
	cmpb	$63, -350(%ebp)
	ja	L119
	movzbl	-350(%ebp), %ecx
	movzbl	-350(%ebp), %eax
	leal	0(,%eax,4), %edx
	movl	12(%ebp), %eax
	flds	-344(%ebp,%ecx,4)
	fmuls	(%edx,%eax)
	fstps	-348(%ebp)
	movzbl	-350(%ebp), %eax
	leal	(%eax,%eax), %ecx
	movl	16(%ebp), %edx
	flds	-348(%ebp)
	fldl	LC10
	faddp	%st, %st(1)
	fnstcw	-352(%ebp)
	movl	-352(%ebp), %eax
	orw	$3072, %ax
	movw	%ax, -354(%ebp)
	fldcw	-354(%ebp)
	fistps	-356(%ebp)
	fldcw	-352(%ebp)
	movl	-356(%ebp), %eax
	subl	$16384, %eax
	movw	%ax, (%ecx,%edx)
	leal	-350(%ebp), %eax
	incb	(%eax)
	jmp	L129
L119:
	leave
	ret
  
   
 
