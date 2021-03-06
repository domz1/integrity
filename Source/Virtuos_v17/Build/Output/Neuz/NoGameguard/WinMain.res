        ��  ��                  4       �� ���     0         ��    �   @ ��      � �       
    S y s t e m   v       �� ���     0        @ �          � A    N e u z C o n s o l e   
 S y s t e m     �P      � ���       � �P     .�  ���       z       �� ���     0        � Ȁ         � ^     D i a l o g   
 S y s t e m    P    �  2   ��� O K         P    �  2   ��� C a n c e l       z       �� ���     0        � Ȁ         � ^     D i a l o g   
 S y s t e m    P    �  2   ��� O K         P    �  2   ��� C a n c e l       �      �� ��     0         �4   V S _ V E R S I O N _ I N F O     ���             ?                        �   S t r i n g F i l e I n f o   �   0 0 0 0 0 4 b 0   4 
  C o m p a n y N a m e     A e o n s o f t     2   F i l e D e s c r i p t i o n     N e u z     8   F i l e V e r s i o n     3 ,   8 ,   2 2 ,   1   *   I n t e r n a l N a m e   N e u z     F   L e g a l C o p y r i g h t   C o p y r i g h t   �$  2 0 0 2     : 	  O r i g i n a l F i l e n a m e   N e u z . e x e     6   P r o d u c t N a m e     M a s q u e r a d e     :   P r o d u c t V e r s i o n   1 ,   0 ,   0 ,   1     D    V a r F i l e I n f o     $    T r a n s l a t i o n       ��
      ��
 ���     0         vs.1.1
;------------------------------------------------------------------------------
; Constants specified by the app
;    c0-c83  = bone matrix index 0 ~ 28
;    c84-c87 = matViewProj
;    c88-c91 = reserved
;    c92     = light direction
;    c93     = material diffuse color * light diffuse color
;    c94     = material ambient color
;    c95     = const 1.0f, 1.0f, 1.0f, 100.0f
;	
;
; Vertex components (as specified in the vertex DECL)
;   v0    = Position
;	v1	  = w1, w2
;	v2.x  = matrix idx
;	v3    = Normal
;	v4    = Texcoords
;------------------------------------------------------------------------------

dcl_position v0;
dcl_blendweight v1;
dcl_blendindices v2;
dcl_normal v3;
dcl_texcoord0 v4;


;------------------------------------------------------------------------------
; Vertex blending
;------------------------------------------------------------------------------

; Transform position for world0 matrix
mov a0.x, v2.x				; matrix index 1
m4x3 r0, v0, c[a0.x]		; r0 = pos * (InvTM * AniTM)
m3x3 r3, v3, c[a0.x]		;normal transform
mul  r1, r0.xyz, v1.x		; r1 = r0 * w1
mul  r4, r3.xyz, v1.x		

mov  a0.x, v2.y				; matrix index 2
m4x3 r0, v0, c[a0.x]		; r0 = pos * (InvTM * AniTM)
m3x3 r3, v3, c[a0.x]		;normal transform
mad  r1, r0.xyz, v1.y, r1.xyz ; w2���ϰ� �����Ŷ� ����
mad  r3, r3.xyz, v1.y, r4.xyz ; w2���ϰ� �����Ŷ� ����

mov  r1.w, c95.x			; r1.w = 1.0f

;m4x4 r0, r0, c88
m4x4 oPos, r1, c84			; oPos = ������� * matViewProj
;mov r0, v0
;mov r0.w, c95.x
;mov oPos, r0


;------------------------------------------------------------------------------
; Lighting calculation
;------------------------------------------------------------------------------
; directional light
dp3 r1.x, r3, -c92   ; N �� L �� ����
lit r1, r1
mul r2, r1.y, c93	; n * diffuse
add r2, r2, c94		; + ambient
min oD0, r2, c95.x     ; clamp if > 1
;mov oD0, r2

;mov oD0, c95.xxxx	; no lighting

;dp3 r0.x, r3, -c92	; vLight dot normal
;sub r1, c88, v0		; vertex -> eyepos
;dp3 r1.w, r1, r1	; vertex->eyepos vector normalize
;rsq r1.w, r1.w
;mul r1, r1, r1.w

;add r2, r1, -c92
;dp3 r2.w, r2, r2
;rsq r2.w, r2.w
;mul r2, r2, r2.w

;dp3 r0.y, r2, r3

;mov r0.w, c89.w		; specular power

;lit r4, r0

;mul r5, r4.z, c89	; specular
;mul r6, r4.y, c90	; c90�� light color�� ��� ���. 1, 1, 1, 1
;mul r6, r6, c93
;add r6, r6, c94		; * diffuse + ambient
;add oD0, r5, r6

;------------------------------------------------------------------------------
; Texture coordinates
;------------------------------------------------------------------------------

; Just copy the texture coordinates
mov oT0.xy,  v4.xy
;mov oT1.xy,  v4.xy

mov oFog, c95.w


l      ��
 ���     0         // Blur Pixel Shader
//
// (c)2003 Virtools

//--- Additional Automatic Parameters
string XFile = "plane.x";   // model
int    BCLR = 0xffffffff;   // background

texture tex0 : TEXTURE0;
//texture tex < string name = "flyff256.bmp"; >;
//float2 texsize <bool isTexelSize=true;>;
float2 texsize = 0.00097;

// transformations
float4x4 World      : WORLD;
float4x4 View       : VIEW;
float4x4 Projection : PROJECTION;

//--- Manual Parameters
float blurFactor = 0.2;
float blurAngle = 0.7;
float blurBurnFactor = 0.25;

//--- Some static pre-computation
static float2 texSizeFactor = texsize * blurFactor * 10;
static float2 UVOffset0 = float2( cos(blurAngle), -sin(blurAngle) )*texSizeFactor;
static float2 UVOffset1 = float2(-sin(blurAngle), -cos(blurAngle) )*texSizeFactor;
static float2 UVOffset2 = float2(-cos(blurAngle),  sin(blurAngle) )*texSizeFactor;
static float2 UVOffset3 = float2( sin(blurAngle),  cos(blurAngle) )*texSizeFactor;

//--- VS Output Structure

struct    VSOUT 
{
    float4 pos : POSITION;
    float2 tex0 : TEXCOORD0;
//    float2 tex1 : TEXCOORD1;
//    float2 tex2 : TEXCOORD2;
//	float2 tex3 : TEXCOORD3;
//	float2 tex4 : TEXCOORD4;
//	float2 tex5 : TEXCOORD5;
//	float2 tex6 : TEXCOORD6;
//	float2 tex7 : TEXCOORD7;
};

//float gWeight[7] = { 0.1, 0.358, 0.773, 1.0, 0.773, 0.358, 0.1 };

//--- Vertex Shader Blur
VSOUT BlurVS( 
    float4 Pos : POSITION,
    float2 Tex0 : TEXCOORD0 )
{
    VSOUT vsout = (VSOUT)0;

	vsout.pos = Pos;
/*
    float4x4 WorldView = mul(World, View);

    float3 P = mul(Pos, (float4x3)WorldView);  // position (view space)
    vsout.pos  = mul(float4(P, 1), Projection);             // position (projected)
*/

    vsout.tex0 = Tex0;

//    vsout.tex0 = Tex0.x + 0.0009765625;		// offset
  //  vsout.tex1 = Tex0;
    //vsout.tex2 = Tex0.x - 0.0009765625;
//	vsout.tex3 = Tex0 + gWeight[3];
//	vsout.tex4 = Tex0 + gWeight[4];
//	vsout.tex5 = Tex0 + gWeight[5];
//	vsout.tex6 = Tex0 + gWeight[6];

    return vsout;
}

//--- Textures Samplers
sampler texSampler0 = sampler_state
{
    texture = <tex0>;
//    MipFilter = LINEAR;
    Minfilter = LINEAR;
    Magfilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float4 BlurPS3_0H( float2 Tex : TEXCOORD0 ) : COLOR
{
    float4 Color = 0;

    Color = tex2D( texSampler0, Tex );
	Color /= 2;
    
    return Color;
}
/*
float4 BlurPS_X( float2 Tex : TEXCOORD0 ) : COLOR
{
    float Weight[7] = { 0.1, 0.358, 0.773, 1.0, 0.773, 0.358, 0.1 };
    float BlurN = 6;
    float4 Color = 0;

    Color += Weight[0] * ( tex2D( texSampler0, Tex + float2( 0, -3.0 / MAP_CX ) ) );    // 
    Color += Weight[1] * ( tex2D( texSampler0, Tex + float2( 0, -2.0 / MAP_CX ) ) );    // 
    Color += Weight[2] * ( tex2D( texSampler0, Tex + float2( 0, -1.0 / MAP_CX ) ) );    // 
    Color += Weight[3] * ( tex2D( texSampler0, Tex + float2( 0,  0.0 / MAP_CX ) ) );    // 
    Color += Weight[4] * ( tex2D( texSampler0, Tex + float2( 0,  1.0 / MAP_CX ) ) );    // 
    Color += Weight[5] * ( tex2D( texSampler0, Tex + float2( 0,  2.0 / MAP_CX ) ) );    // 
    Color += Weight[6] * ( tex2D( texSampler0, Tex + float2( 0,  3.0 / MAP_CX ) ) );    // 
    
    return Color / BlurN;
}

float4 BlurPS_Y( float2 Tex : TEXCOORD0 ) : COLOR
{
    float Weight[7] = { 0.1, 0.358, 0.773, 1.0, 0.773, 0.358, 0.1 };
    float BlurN = 6;
    float4 Color = 0;

    Color += Weight[0] * ( tex2D( texSampler0, Tex + float2( 0, -3.0 / MAP_CY ) ) );    // 
    Color += Weight[1] * ( tex2D( texSampler0, Tex + float2( 0, -2.0 / MAP_CY ) ) );    // 
    Color += Weight[2] * ( tex2D( texSampler0, Tex + float2( 0, -1.0 / MAP_CY ) ) );    // 
    Color += Weight[3] * ( tex2D( texSampler0, Tex + float2( 0,  0.0 / MAP_CY ) ) );    // 
    Color += Weight[4] * ( tex2D( texSampler0, Tex + float2( 0,  1.0 / MAP_CY ) ) );    // 
    Color += Weight[5] * ( tex2D( texSampler0, Tex + float2( 0,  2.0 / MAP_CY ) ) );    // 
    Color += Weight[6] * ( tex2D( texSampler0, Tex + float2( 0,  3.0 / MAP_CY ) ) );    // 
    
    return Color / BlurN;
}
*/


technique BlurTech
{
/*
    pass pX
    {
        VertexShader = compile vs_2_0 BlurVS();
        PixelShader = compile ps_2_0 BlurPS_X2();
    }
    pass pY
    {
        VertexShader = compile vs_1_1 BlurVS();
        PixelShader = compile ps_2_0 BlurPS_Y();
    }
*/
    pass p
    {
        VertexShader = compile vs_1_1 BlurVS();
//        PixelShader = compile ps_1_1 BlurPS3_0H();
		PixelShader =
		asm
		{
			ps_1_1
			def c0, 0.910f, 0.910f, 0.910f, 1.0	
			tex t0

			mul r0, t0, c0	// * 0.5
		};
    }
/*
    pass pM
    {
        VertexShader = compile vs_1_1 BlurVS();
        PixelShader = compile ps_1_1 BlurPS3_0M();
    }
    pass pL
    {
        VertexShader = compile vs_1_1 BlurVS();
        PixelShader = compile ps_1_1 BlurPS3_0L();
    }
*/
}
�U      ��
 ���     0         
float4x4	mWVP;           // ����
float4x4	mProj;
float4x4	mView;

float4      vLightDir;      // ��������

float3      vEyePos;		// ī�޶���ġ
float4      vFog;		// (Far/(Far-Near), -1/(Far-Near))


float4x3	mBoneMatrix[28];

float4 GetAmbientDiffuse( float3 N, float3 L, const float basicAmbient, const float minAmbient );
float4 GetSpecular( float3 R, float3 L );

texture	Tex;            // �ؽ�ó
texture Tex_Diffuse;
texture Tex_Bump;
texture Tex_Specular;
texture	Tex_EnvironmentMap;

// **********************************************
// �ؽ�ó ������Ʈ ����
// **********************************************
sampler Samp_Diffuse = sampler_state
{
    Texture = <Tex_Diffuse>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
};

sampler Samp_Bump = sampler_state
{
    Texture = <Tex_Bump>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;

    AddressU = Wrap;
    AddressV = Wrap;
};

sampler Samp_Specular = sampler_state
{
    Texture = <Tex_Specular>;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;

    AddressU = Wrap;
    AddressV = Wrap;
};

samplerCUBE EnvironmentSampler = sampler_state
{  
    Texture = (Tex_EnvironmentMap); 
    MipFilter = LINEAR; 
    MinFilter = LINEAR; 
    MagFilter = LINEAR; 
}; 



///////////////////////////////////////////////////////////////////////////////////////////////////

// light intensity
float4 I_a = { 0.6f, 0.6f, 0.6f, 1.0f };    // ambient
float4 I_d = { 0.4f, 0.4f, 0.4f, 1.0f };    // diffuse
float4 I_s = { 0.7f, 0.7f, 0.7f, 1.0f };    // specular

float4 k_a : MATERIALAMBIENT = { 0.65f, 0.65f, 0.65f, 1.0f };    // ambient
float4 k_d : MATERIALDIFFUSE = { 0.55f, 0.55f, 0.55f, 1.0f };    // diffuse
float4 k_s : MATERIALSPECULAR= { 0.3f, 0.3f, 0.3f, 1.0f };    // specular
float  n   : MATERIALPOWER = 64.0f;                           // power


// **********************************************
// �������̴����� �ȼ����̴��� �ѱ�� ������
// **********************************************
struct VS_OUTPUT_Phong
{
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
	float4 Diffuse		: COLOR0;
	float4 Specular		: COLOR1;
	float3 N			: TEXCOORD1;
	float3 Eye			: TEXCOORD2;
	float  Fog			: FOG;
};

struct VS_OUTPUT_Gouraud
{
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
	float4 Diffuse		: COLOR0;
	float  Fog			: FOG;
};


// **********************************************
// ���� ���̵�
// ----------------------------------------------
// �������̴�
VS_OUTPUT_Gouraud VS_Gouraud( float4 Pos : POSITION, float2 Tex : TEXCOORD0, float3 Normal : NORMAL )
{
	VS_OUTPUT_Gouraud Out = (VS_OUTPUT_Gouraud)0;     // ��µ���Ÿ �ʱ�ȭ

	Out.Pos = mul( Pos, mWVP );       // ���� ���庯ȯ

	float3 L = -vLightDir;
	float3 N = normalize( Normal );

	float3	V = normalize(vEyePos - Pos.xyz);   // �ü�����
	float3  H = normalize( L+V );				// HALF vector(L+V)

	Out.Diffuse   = I_a * k_a + I_d * k_d * max(0, dot(N, L));

	Out.Tex = Tex;

	// �Ÿ�����
	Out.Fog = vFog.x + Out.Pos.w * vFog.y;

	return Out;  // �ȼ����̴��� �ѱ��
}

// �ȼ����̴�
float4 PS_Gouraud( VS_OUTPUT_Gouraud In ) : COLOR
{
	return In.Diffuse * tex2D( Samp_Diffuse, In.Tex );// + In.Specular;
}	       


// -------------------------------------------------------------
// �������̴����� �ȼ����̴��� �ѱ�� ������
// -------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Pos			: POSITION;

    float2 Tex			: TEXCOORD0;	// �����ؽ�ó ��ǥ
    float3 L			: TEXCOORD1;	// ��������
    float3 E			: TEXCOORD2;	// ��������
	float  Fog			: FOG;
};
// -------------------------------------------------------------
// ��鷻��
// -------------------------------------------------------------
VS_OUTPUT VS_BUMP(
      float4 Pos      : POSITION,          // ������ġ��ǥ
      float3 Normal   : NORMAL,            // ��������
      float3 Tangent  : TANGENT0,          // ��������
      float2 Texcoord : TEXCOORD0          // �ؽ�ó��ǥ
){
	VS_OUTPUT Out = (VS_OUTPUT)0;        // ��µ�����
	
	// ��ǥ��ȯ
	Out.Pos = mul(Pos, mWVP);
	
	// ���ÿ� �ؽ�ó��ǥ
	Out.Tex = Texcoord;

	// ��ǥ�躯ȯ ����
	float3 N = Normal;
	float3 T = Tangent;
	float3 B = cross(N,T);

	// �ݿ��ݻ�� ����
	float3 E = vEyePos - Pos.xyz;	// �ü�����
	Out.E.x = dot(E,T);
	Out.E.y = dot(E,B);
	Out.E.z = dot(E,N);

	float3 L = -vLightDir.xyz;		// ��������
	Out.L.x = dot(L,T);
	Out.L.y = dot(L,B);
	Out.L.z = dot(L,N);

	// �Ÿ�����
	Out.Fog = vFog.x + Out.Pos.w * vFog.y;

	return Out;
}
// -------------------------------------------------------------
float4 PS_BUMP(VS_OUTPUT In) : COLOR
{   
	float3 N = 2.0f*tex2D( Samp_Bump, In.Tex ).xyz-1.0f;// ���������κ��� ����
	float3 L = normalize(In.L);						// ��������

	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;
	float4 fSpecTexture;

	fAmbientDiffuse = GetAmbientDiffuse( N, L, 0.0f, 0.0f );
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );
	fSpecTexture    = tex2D( Samp_Specular, In.Tex );

	if( fSpecTexture.r == 0.0f && fSpecTexture.g == 0.0f && fSpecTexture.b == 0.0f )
	{
		return fAmbientDiffuse * fDiffuseTexture;
	}
	else
	{
		float4 fColor = fAmbientDiffuse * fDiffuseTexture;
		fColor  *= fSpecTexture;

		// ����ŧ�� �ֱ� ���������� �˻� �������̸� �ݼ����� �ȳ���
		if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
		{
			float3 R = reflect(-normalize(In.E), N);
			fColor  += GetSpecular( R, L );
		}

		return fColor;
	}
}

float4 PS_Bump_Env(VS_OUTPUT In) : COLOR
{   
	float3 N = 2.0f*tex2D( Samp_Bump, In.Tex ).xyz-1.0f;// ���������κ��� ����
	float3 L = normalize(In.L);						// ��������

	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;
	float4 fSpecTexture;

	fAmbientDiffuse = GetAmbientDiffuse( N, L, 0.0f, 0.0f );
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );
	fSpecTexture    = tex2D( Samp_Specular, In.Tex );


   	float3 R = reflect(-normalize(In.E), N);
  	float4 fEnvTexture = texCUBE(EnvironmentSampler, R);
	float4 flerpColor = lerp( fDiffuseTexture, fEnvTexture, 0.2f );

	float4 fColor = fAmbientDiffuse * flerpColor;
	//fColor = fColor * flerpColor;


	if( fSpecTexture.r == 0.0f && fSpecTexture.g == 0.0f && fSpecTexture.b == 0.0f )
	{
		return fAmbientDiffuse * fDiffuseTexture;
	}
	else
	{
		fColor  *= fSpecTexture;

		// ����ŧ�� �ֱ� ���������� �˻� �������̸� �ݼ����� �ȳ���
		if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
		{
			fColor  += GetSpecular( R, L );
		}

		return fColor;
	}
}
float4 PS_BUMP_ALPHA(VS_OUTPUT In) : COLOR
{   
	float3 N = 2.0f*tex2D( Samp_Bump, In.Tex ).xyz-1.0f;// ���������κ��� ����
	float3 L = normalize(In.L);						// ��������

	float4 fAmbientDiffuse;

	fAmbientDiffuse = GetAmbientDiffuse( N, L, 0.0f, 0.0f );

	float4 fDiffuseTexture;
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );

	float4 fColor;

	fColor = (fAmbientDiffuse * fDiffuseTexture );
	return fColor;
}


struct VS_OUTPUT_SPEC
{
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
	float3 N			: TEXCOORD1;
	float3 Eye			: TEXCOORD2;
	float  Fog			: FOG;
};

VS_OUTPUT_SPEC VS_SPEC( float4 Pos : POSITION, float2 Tex : TEXCOORD0, float3 Normal : NORMAL )
{
	VS_OUTPUT_SPEC Out = (VS_OUTPUT_SPEC)0;     // ��µ���Ÿ �ʱ�ȭ

	Out.Pos = mul( Pos, mWVP );       // ���� ���庯ȯ

	float3 L   = -vLightDir;
	Out.N      = normalize( Normal ); // ���� �������
	Out.Eye    = vEyePos - Pos.xyz;   // �ü�����

	Out.Tex = Tex;                    // �ؽ�ó ����

	// �Ÿ�����
	Out.Fog = vFog.x + Out.Pos.w * vFog.y;

	return Out;  // �ȼ����̴��� �ѱ��
}

float4 PS_SPEC( VS_OUTPUT_SPEC In ) : COLOR
{
	// ���� �� �ݿ� �ݻ�
	float3	L = normalize(-vLightDir.xyz);
	float3	V = normalize( In.Eye );

	// HALF vector(L+V)
	float3  H = normalize( L+V ); 
	float3  N = normalize( In.N );

	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;
	float4 fSpecTexture;

	fAmbientDiffuse = I_a * k_a + I_d * k_d * max(0, dot(N, L));
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );
	fSpecTexture    = tex2D( Samp_Specular, In.Tex );

   	float3 R = reflect(-normalize(In.Eye), N);
  	float4 fEnvTexture = texCUBE(EnvironmentSampler, R);
	float4 flerpColor = lerp( fDiffuseTexture, fEnvTexture, 0.25f );

	float4 fColor = fAmbientDiffuse * flerpColor;


	if( fSpecTexture.r == 0.0f && fSpecTexture.g == 0.0f && fSpecTexture.b == 0.0f )
	{
		return ( fAmbientDiffuse * fDiffuseTexture );
	}
	else
	{
		fColor  *= fSpecTexture;

		// ����ŧ�� �ֱ� ���������� �˻� �������̸� �ݼ����� �ȳ���
		if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
		{
			fColor  += ( GetSpecular( R, L ) * fSpecTexture );
		}

		return fColor;
	}
}

float4 PS_SPEC_ALPHA( VS_OUTPUT_SPEC In ) : COLOR
{
	// ���� �� �ݿ� �ݻ�
	float3	L = normalize(-vLightDir.xyz);
	float3	V = normalize( In.Eye );

	// HALF vector(L+V)
	float3  H = normalize( L+V ); 
	float3  N = normalize( In.N );

	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;

	fAmbientDiffuse = I_a * k_a + I_d * k_d * max(0, dot(N, L));
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );

	float4 fColor = fAmbientDiffuse * fDiffuseTexture;
	return fColor;
}

// ������� ����
struct VS_OUTPUT_SKIN
{
	float4 Pos     : POSITION;
	float4 Diffuse : COLOR0;
	float2 Tex     : TEXCOORD0;
	float  Fog	   : FOG;
};

// �������̴� �Լ� ����
VS_OUTPUT_SKIN VS_SkinBasic( 
				    float3 Pos			  : POSITION,
					float4 BlendWeights   : BLENDWEIGHT,
					float4 BlendIndices	  : BLENDINDICES,
					float3 Normal		  : NORMAL,
					float2 Tex			  : TEXCOORD0 )
{
	// �������
    VS_OUTPUT_SKIN Out = (VS_OUTPUT_SKIN)0;

	// �ӽú���
	float3 p;
	float3 p2 = float3( 0, 0, 0 );

	// ù��° ��Ʈ���� �ȷ�Ʈ����
	p = mul( float4(Pos,1), mBoneMatrix[BlendIndices.x/3] );
	p = p * BlendWeights.x;							
	p2 = float4(p,0);						

	// �ι�° ��Ʈ���� �ȷ�Ʈ����
	p = mul( float4(Pos,1), mBoneMatrix[BlendIndices.y/3] );
	p = p * BlendWeights.y;
	p2 = p2 + float4(p,0);

    Out.Pos = mul( float4(p2, 1), mWVP );	
			
	Out.Diffuse   = (I_a * k_a + I_d * k_d * max(0, dot(normalize( Normal ), -vLightDir)));

	Out.Tex = Tex;

	// �Ÿ�����
	Out.Fog = vFog.x + Out.Pos.w * vFog.y;

    return Out;
}


// ������� ����
struct VS_OUTPUT_SKIN_BUMP
{
	float4 Pos     : POSITION;

	float2 Tex     : TEXCOORD0;
    float3 L	   : TEXCOORD1;	// ��������
    float3 E	   : TEXCOORD2;	// ��������
	float  Fog	   : FOG;
};

// �������̴� �Լ� ����
VS_OUTPUT_SKIN_BUMP VS_SkinBUMP(     
	float3 Pos			  : POSITION,
    float4 BlendWeights   : BLENDWEIGHT,
    float4 BlendIndices	  : BLENDINDICES,
    float3 Normal		  : NORMAL,
    float3 Tangent		  : TANGENT0,
    float2 Tex			  : TEXCOORD0 )
{
	// �������
    VS_OUTPUT_SKIN_BUMP Out = (VS_OUTPUT_SKIN_BUMP)0;

	// �ӽú���
	float3 p;
	float3 p2 = float3( 0, 0, 0 );

	// ù��° ��Ʈ���� �ȷ�Ʈ����
	p = mul( float4(Pos,1), mBoneMatrix[BlendIndices.x/3] );
	p = p * BlendWeights.x;							
	p2 = float4(p,0);						

	// �ι�° ��Ʈ���� �ȷ�Ʈ����
	p = mul( float4(Pos,1), mBoneMatrix[BlendIndices.y/3] );
	p = p * BlendWeights.y;
	p2 = p2 + float4(p,0);

    Out.Pos = mul( float4(p2, 1), mWVP );			

	Out.Tex = Tex;

	// ��ǥ�躯ȯ ����
	float3 N = Normal;
	float3 T = Tangent;
	float3 B = cross(N,T);

	// �ݿ��ݻ�� ����
	float3 E = vEyePos - Pos.xyz;	// �ü�����
	Out.E.x = (dot(E,T));
	Out.E.y = (dot(E,B));
	Out.E.z = (dot(E,N));

	float3 L = -vLightDir.xyz;		// ��������
	Out.L.x = (dot(L,T));
	Out.L.y = (dot(L,B));
	Out.L.z = (dot(L,N));

	// �Ÿ�����
	Out.Fog = vFog.x + Out.Pos.w * vFog.y;

    return Out;
}
float4 PS_SkinBUMP(VS_OUTPUT_SKIN_BUMP In) : COLOR
{ 
	float3 N = 2.0f*tex2D( Samp_Bump, In.Tex ).xyz-1.0f;
	float3 L = normalize(In.L);	
						
	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;
	float4 fSpecTexture;

	fAmbientDiffuse = GetAmbientDiffuse( N, L, 0.0f, 0.5f );
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );
	fSpecTexture    = tex2D( Samp_Specular, In.Tex );

	if( fSpecTexture.r == 0.0f && fSpecTexture.g == 0.0f && fSpecTexture.b == 0.0f )
	{
		return fAmbientDiffuse * fDiffuseTexture;
	}
	else
	{
		float4 fColor = fAmbientDiffuse * fDiffuseTexture;
		fColor  *= fSpecTexture;

		// ����ŧ�� �ֱ� ���������� �˻� �������̸� �ݼ����� �ȳ���
		if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
		{
			float3 R = reflect(-normalize(In.E), N);
			fColor  += GetSpecular( R, L );
			//fColor  *= fSpecTexture;
		}

		return fColor;
	}
}

float4 PS_SkinBumpEnv(VS_OUTPUT_SKIN_BUMP In) : COLOR
{ 
	float3 N = 2.0f*tex2D( Samp_Bump, In.Tex ).xyz-1.0f;
	float3 L = normalize(In.L);	
						
	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;
	float4 fSpecTexture;

  	float3 R = reflect(-normalize(In.E), N);

	fAmbientDiffuse = GetAmbientDiffuse( N, L, 0.0f, 0.5f );
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );
	fSpecTexture    = tex2D( Samp_Specular, In.Tex );

//////////////////////////////////////////////////////////////////////////////////////
   	float4 fEnvTexture = texCUBE(EnvironmentSampler, R);
	float4 flerpColor = lerp( fDiffuseTexture, fEnvTexture, 0.2f );

	float4 fColor = fAmbientDiffuse * flerpColor;
	//fColor = fColor * flerpColor;

	if( fSpecTexture.r == 0.0f && fSpecTexture.g == 0.0f && fSpecTexture.b == 0.0f )
	{
		return fAmbientDiffuse * fDiffuseTexture;
	}
	else
	{
		fColor  *= fSpecTexture;

		// ����ŧ�� �ֱ� ���������� �˻� �������̸� �ݼ����� �ȳ���
		if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
		{
			fColor  += GetSpecular( R, L );
		}

		return fColor;
	}
}
float4 PS_SkinBUMP_ALPHA(VS_OUTPUT_SKIN_BUMP In) : COLOR
{ 
	float3 N = 2.0f*tex2D( Samp_Bump, In.Tex ).xyz-1.0f;
	float3 L = normalize(In.L);	
						
	float4 fAmbientDiffuse;

	fAmbientDiffuse = GetAmbientDiffuse( N, L, 0.0f, 0.5f );

	float4 fDiffuseTexture;
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );

	float4 fColor;

	fColor = (fAmbientDiffuse * fDiffuseTexture );

	return fColor;
}





struct VS_OUTPUT_SKIN_SPEC_ENV
{
	float4 Pos     : POSITION;

	float2 Tex     : TEXCOORD0;
    float3 L	   : TEXCOORD1;	// ��������
    float3 E	   : TEXCOORD2;	// ��������
    float3 N	   : TEXCOORD3;	// ��������
	float  Fog	   : FOG;
};

// �������̴� �Լ� ����
VS_OUTPUT_SKIN_SPEC_ENV VS_SkinSPEC_ENV(     
	float3 Pos			  : POSITION,
    float4 BlendWeights   : BLENDWEIGHT,
    float4 BlendIndices	  : BLENDINDICES,
    float3 Normal		  : NORMAL,
    float3 Tangent		  : TANGENT0,
    float2 Tex			  : TEXCOORD0 )
{
	// �������
    VS_OUTPUT_SKIN_SPEC_ENV Out = (VS_OUTPUT_SKIN_SPEC_ENV)0;

	// �ӽú���
	float3 p;
	float3 p2 = float3( 0, 0, 0 );

	// ù��° ��Ʈ���� �ȷ�Ʈ����
	p = mul( float4(Pos,1), mBoneMatrix[BlendIndices.x/3] );
	p = p * BlendWeights.x;							
	p2 = float4(p,0);						

	// �ι�° ��Ʈ���� �ȷ�Ʈ����
	p = mul( float4(Pos,1), mBoneMatrix[BlendIndices.y/3] );
	p = p * BlendWeights.y;
	p2 = p2 + float4(p,0);

    Out.Pos = mul( float4(p2, 1), mWVP );			

	Out.Tex = Tex;

	// �ݿ��ݻ�� ����
	Out.E = vEyePos - Pos.xyz;	// �ü�����
	Out.L = -vLightDir.xyz;		// ��������

	// �Ÿ�����
	Out.Fog = vFog.x + Out.Pos.w * vFog.y;

	Out.N   = normalize( Normal );

    return Out;
}

float4 PS_SkinSPEC_ENV(VS_OUTPUT_SKIN_SPEC_ENV In) : COLOR
{ 
	// ���� �� �ݿ� �ݻ�
	float3	L = normalize( In.L);
	float3	V = normalize( In.E );

	// HALF vector(L+V)
	float3  H = normalize( L+V ); 
	float3  N = normalize( In.N );

	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;
	float4 fSpecTexture;

	fAmbientDiffuse = I_a * k_a + I_d * k_d * max(0, dot(N, L));
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );
	fSpecTexture    = tex2D( Samp_Specular, In.Tex );

   	float3 R = reflect(-normalize(In.E), N);
  	float4 fEnvTexture = texCUBE(EnvironmentSampler, R);
	float4 flerpColor = lerp( fDiffuseTexture, fEnvTexture, 0.2f );

	float4 fColor = fAmbientDiffuse * flerpColor;

	if( fSpecTexture.r == 0.0f && fSpecTexture.g == 0.0f && fSpecTexture.b == 0.0f )
	{
		return (fAmbientDiffuse * fDiffuseTexture);
	}
	else
	{
		fColor  *= fSpecTexture;

		// ����ŧ�� �ֱ� ���������� �˻� �������̸� �ݼ����� �ȳ���
		if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
		{
			fColor  += ( GetSpecular( R, L ) * fSpecTexture ) ;
		}

		return fColor;
	}
}

float4 PS_SkinSPEC_ENV_AHPHA(VS_OUTPUT_SKIN_SPEC_ENV In) : COLOR
{ 
	// ���� �� �ݿ� �ݻ�
	float3	L = normalize( In.L);
	float3	V = normalize( In.E );

	// HALF vector(L+V)
	float3  H = normalize( L+V ); 
	float3  N = normalize( In.N );

	float4 fAmbientDiffuse;
	float4 fDiffuseTexture;

	fAmbientDiffuse = I_a * k_a + I_d * k_d * max(0, dot(N, L));
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );

	float4 fColor = fAmbientDiffuse * fDiffuseTexture;

	return fColor;
}

float4 GetAmbientDiffuse( float3 N, float3 L, const float basicAmbient, const float minAmbient )
{
	float4 ambient = I_a * k_a;
	float4 diffuse = I_d * k_d;
	float4 diff = max( minAmbient, saturate( dot( N, L ) )+basicAmbient );
	float shadow = saturate(0.05f * diff);

//	return ambient + shadow * (diffuse * diff);

	float4 fResult = ambient + diffuse * shadow;

	if( fResult.a > 1.0f )
		fResult.a = 1.0f;

	if( fResult.r > 1.0f )
		fResult.r = 1.0f;

	if( fResult.g > 1.0f )
		fResult.g = 1.0f;

	if( fResult.b > 1.0f )
		fResult.b = 1.0f;

	return fResult;
}

float4 GetSpecular( float3 R, float3 L )
{
	return I_s * k_s * pow( max( 0, saturate(dot( R, L )) ), n );
}



float4 GlowColor     = float4(0.5f, 0.2f, 0.2f, 1.0f);
float4 GlowAmbient   = float4(0.2f, 0.2f, 0.0f, 0.0f);
float  GlowThickness = 0.1f;
//float  GlowThickness = 0.03f;


struct VSGLOW_OUTPUT
{
    float4 Position : POSITION;
    float4 Diffuse  : COLOR;
	float2 Tex     : TEXCOORD0;
	float  Fog	   : FOG;
};

VSGLOW_OUTPUT VSGlow(
    float4 Position : POSITION, 
    float3 Normal   : NORMAL,
	float2 Tex	    : TEXCOORD0 )
{
    VSGLOW_OUTPUT Out = (VSGLOW_OUTPUT)0;

    float4 N = normalize(mul(Normal, mWVP));     // normal (view space)
    float4 P = mul(Position, mWVP) + GlowThickness * N;    // displaced position (view space)
    float3 A = float3(0, 0, 1);                                 // glow axis

    float Power;

    Power  = dot(N, A);
    Power *= Power;
    Power -= 1;
    Power *= Power;     // Power = (1 - (N.A)^2)^2 [ = ((N.A)^2 - 1)^2 ]

    Out.Position = P;//mul(float4(P, 1), mProj);   // projected position
    Out.Diffuse  = GlowColor * Power + GlowAmbient; // modulated glow color + glow ambient

   	Out.Fog = vFog.x + Out.Position.w * vFog.y;

	Out.Tex = Tex;

    return Out;    
}

float4 PSGlow(VSGLOW_OUTPUT In) : COLOR
{ 
	float4 fDiffuseTexture;
	fDiffuseTexture = tex2D( Samp_Diffuse, In.Tex );

	float4 fColor = In.Diffuse;

	if( fDiffuseTexture.r > 0.0f && fDiffuseTexture.g > 0.0f && fDiffuseTexture.b > 0.0f )
	{
		fColor = 0;
	}

	return fColor;

	/*
	if( fDiffuseTexture.a == 0.0f )
	{
		return 0;
		return In.Diffuse;
	}
	else
	{
		return In.Diffuse;
	}
	*/
}


// **********************************************
// ��ũ��
// **********************************************
technique	TShader
{
	pass p0
	{
		VertexShader = compile vs_1_1 VS_Gouraud();
		PixelShader  = NULL;

		FogEnable = true;			// ���׻��
        FogVertexMode = Linear;		// ���� ����

	    AddressU[0] = Wrap;
	    AddressV[0] = Wrap;
	}

	pass p1
	{
		VertexShader = compile vs_1_1 VS_SPEC();
		PixelShader  = compile ps_2_0 PS_SPEC();

		FogEnable = true;			// ���׻��
        FogVertexMode = Linear;		// ���� ����
		
	    AddressU[0] = Wrap;
	    AddressV[0] = Wrap;
	}
	pass p2
	{
		VertexShader = compile vs_1_1 VS_SPEC();
		PixelShader  = compile ps_2_0 PS_SPEC_ALPHA();

		FogEnable = true;			// ���׻��
        FogVertexMode = Linear;		// ���� ����

		AlphaBlendEnable = TRUE;
		SrcBlend  = SRCCOLOR;
		DestBlend = INVSRCCOLOR;
		CullMode  = NONE;

	    AddressU[0] = Wrap;
	    AddressV[0] = Wrap;
	}

	pass p3
	{
		VertexShader = compile vs_1_1 VS_SkinBasic();
		PixelShader  = NULL;
		
		FogEnable = true;			// ���׻��
        FogVertexMode = Linear;		// ���� ����
	}

	pass p4
	{
		VertexShader = compile vs_1_1 VS_SkinSPEC_ENV();
		PixelShader  = compile ps_2_0 PS_SkinSPEC_ENV();

		FogEnable = true;			// ���׻��
        FogVertexMode = Linear;		// ���� ����

	    AddressU[0] = Wrap;
	    AddressV[0] = Wrap;
	}

	pass p5
	{
		VertexShader = compile vs_1_1 VS_SkinSPEC_ENV();
		PixelShader  = compile ps_2_0 PS_SkinSPEC_ENV_AHPHA();
		
		FogEnable = true;			// ���׻��
        FogVertexMode = Linear;		// ���� ����
		CullMode  = NONE;

		AlphaBlendEnable = TRUE;
		SrcBlend = SRCCOLOR;
		DestBlend = INVSRCCOLOR;
	}

	pass p6
	{
		VertexShader = compile vs_1_1 VSGlow();
        PixelShader  = compile ps_2_0 PSGlow();
        
        // no texture
        Texture[0] = NULL;

        // enable alpha blending
        AlphaBlendEnable = TRUE;
        SrcBlend         = ONE;
        DestBlend        = ONE;

        // set up texture stage states to use the diffuse color
        ColorOp[0]   = SELECTARG2;
        ColorArg2[0] = DIFFUSE;
        AlphaOp[0]   = SELECTARG2;
        AlphaArg2[0] = DIFFUSE;

        ColorOp[1]   = DISABLE;
        AlphaOp[1]   = DISABLE;

		CullMode  = NONE;
	}

}
  �      �� ��               (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       G..G..G..G..G..G..G..G..                                          G..G..                     G..�ȸ�ȸ�ȸ�ȸ�ȸ���G..                                          G..�ȸG..               G..�ȸΕ��ȸ�ȸ������G..                                       G..�ȸ�ȸG..         G..Ε��dVΕ��ȸ���������G..                                       G..�ȸ�������ȸG..G..Ε��dV�dV�ȸ�������ȸ���G..                                       G..�ȸ�ȸ�������ȸG..G..G..Ε��dV�dV�ȸ������Ε��ȸ���G..                                    G..�ȸΕ��ȸ�������ȸΕ�Ε��dV�dV�ȸ������Ε��ȸ������G..                                    G..�ȸ�ȸΕ�Ε��ȸ�������ȸ�dV�dV�ȸ�������dV�ȸ���G..G..G..                                    G..�ȸΕ�Ε��dVΕ��ȸ�������ȸ�ȸ�������dVΕ��ȸG..                                          G..�ȸΕ�Ε��dV�dVΕ��ȸ�������������dV�dV�ȸG..                                             G..�ȸ�ȸΕ�Ε��dV�dVΕ��ȸ�������������dVΕ�G..                                                G..�ȸΕ�Ε��dV�dVΕ��ȸ�ȸ������������Ε�Ε�G..                                             G..�ȸΕ�Ε��dVΕ��ȸ�ȸ������������������Ε�G..                                          G..�ȸ�ȸΕ��dVΕ��ȸ�ȸ���������Ε�Ε�����������ȸG..                                       G..�ȸΕ�Ε�Ε��ȸ�ȸ���������Ε�Ε�Ε�Ε�����������ȸG..                                 G..�ȸΕ�Ε��ȸ�ȸ���������Ε�Ε��ȸ�ȸ�ȸΕ�����������ȸG..                              G..�ȸ�ȸΕ��ȸ�ȸ���������Ε��ȸ�ȸ�ȸ�ȸ�������������������ȸG..                              G..�ȸΕ��ȸ�ȸ���������Ε��ȸ�ȸ�ȸ���������������������G..G..G..                           G..�ȸ�ȸ�ȸ����������ȸ�ȸ�ȸ������������������T41G..G..                                    G..�ȸ�ȸ�ȸ����������ȸ������������������T41G..G..                                             G..�ȸ�ȸ������������������������T41G..G..                                                   G..�ȸ������������������T41G..G..                                                            G..�ȸ������������T41G..G..                                                                     G..������T41G..G..                                                                              G..G..G..                                                                                       ������������������������������?�� � �  �  �  �  � �� �� �� �� �� �� ��  ��  ��  �� �� ?���� �� ��������       �� ���     0              @   �   �      �� ��                 (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    G..G..                                                                        G..�ȸ�ȸG..                                                         G..G..G..      G..�ȸ�ȸ�ȸG..                                                         G..�ȸΕ�G..G..G..�ȸ����ȸG..                                                               G..�ȸΕ�G..G..Ε��ȸ����ȸG..                                                                     G..����ȸΕ��ȸ����ȸG..                                                                  G..����������ȸ�dVG..                                                               G..G..G..Ε��ȸ������Ε�G..                                                               G..�ȸ�ȸΕ�Ε�Ε��ȸ����ȸG..                                                         G..�ȸ�ȸ�ȸΕ�Ε�Ε�Ε�G..����ȸG..                                                   G..�ȸ�ȸ�ȸ�ȸΕ�Ε�Ε�G..   G..����ȸG..                                                G..�ȸ�ȸ�ȸ�ȸ������������G..      G..���G..                                             G..�ȸ�ȸ�ȸ�ȸ���������������G..         G..G..                                          G..�ȸ�ȸ�ȸ�ȸ���������������G..                                                         G..�ȸ�ȸ�ȸ�ȸ���������������G..                                                         G..�ȸ�ȸ�ȸ�ȸ���������������G..                                                      G..�ȸ�ȸ�ȸ�ȸ���������������G..                                                      G..G..�ȸ�ȸ�ȸ�ȸ���������������G..                                                      G..�ȸ�ȸ�ȸ�ȸ�ȸ���������������G..                                                      G..�ȸ�ȸ�ȸ�ȸ�ȸ���������������G..                                                      G..�ȸ�ȸ�ȸ�ȸ�ȸ���������������G..                                                         G..������������������������������G..                                                            G..���������������������������G..                                                               G..���������������������������G..                                                               G..������������������������G..                                                                  G..���������������������G..                                                                     G..������������������G..                                                                           G..G..G..G..G..G..                                                                           ���������������������>���� �� ?����� �� ��� �� ?��?��?��?� �� �� ?�� �� �������� �� �� �� �� ?�� �� �������       �� ���     0              @   �   �      �� ��              	 (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   G..                                                                                          G..G..                                                                                       G..���G..                                                                                    G..������G..                                                                                 G..���������G..                                    G..������������G..G..G..G..G..G..G..                        G..G..G..G..G..G..G..G..Ε��������������������������������ȸG..G..                  G..G..�ȸ���������������������������������������������������������������G..            G..�ȸ������������������������������������������������������������������������G..         G..�ȸ������������������������������������������������������������������������������G..         G..���������������������������������������������������������������������������������G..         G..���������������������������������������������������������������������������������G..         G..���������Ε�Ε�Ε����������Ε�Ε�Ε����������Ε�Ε�Ε����������Ε�Ε�Ε����������G..         G..���������Ε�Ε�Ε����������Ε�Ε�Ε����������Ε�Ε�Ε����������Ε�Ε�Ε����������G..         G..���������Ε�Ε�Ε����������Ε�Ε�Ε����������Ε�Ε�Ε����������Ε�Ε�Ε����������G..         G..���������������������������������������������������������������������������������G..         G..���������������������������������������������������������������������������������G..         G..���������������������������������������������������������������������������������G..         G..������������������������������������������������������������������������������G..               T41�������������������������������������������������������������������������ȸG..               G..�������������������������������������������������������������������ȸG..G..                     G..T41�������������������������������ȸG..G..G..G..G..G..G..G..G..G..                                 G..G..G..G..G..G..G..G..G..G..G..                                                   ����������������������������������������������������� ��  ?�  �                                   �  �  �  ���       �� ���     0              @   �   �      �� ��               (       @         �                                                                                                                                                                                                                                                                                                                                 G..G..G..                                                                     G..G..Ε�Ε�Ε�G..G..                                                         G..G..Ε��ȸ�ȸ�ȸΕ�Ε�Ε�G..G..                                             G..G..Ε��ȸ�ȸ�ȸ�ȸ�ȸΕ�Ε�Ε�Ε�Ε�G..G..                                 G..G..Ε��ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε�G..G..                              G..G..Ε��ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                              G..Ε��ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                              G..�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ���Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                              G..�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ������dV�dV����ȸΕ�Ε�Ε�Ε�Ε�Ε�G..                              G..�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ������dV�dVΕ�Ε��dV�dV����ȸΕ�Ε�Ε�Ε�G..                              G..�ȸ�ȸ�ȸ�ȸ������dV�dVΕ�Ε��dV�dV�dV�dV�dV�dV����ȸΕ�Ε�G..                              G..�ȸ�ȸ������Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�dV�dV�dV�dV����ȸG..                              G..�ȸ���Ε�Ε�Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�dV�dV�dV�dV�dV�dVG..                           G..�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�dV�dV�dV�dV�dV�ȸΕ�G..                        G..G..�ȸ���Ε�Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�dV�dV�dVΕ�Ε��ȸΕ�Ε�G..                           G..G..�ȸ���Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�dVΕ�Ε��dV�dV�ȸΕ�Ε�Ε�G..                                 G..G..�ȸ���Ε��dV�dV�dV�dV�dVΕ�Ε��dV�dV�dV�dV�ȸΕ�Ε�Ε�G..                                       G..G..�ȸ���dV�dVΕ�Ε��dV�dV�dV�dV�dV�dV�ȸΕ�Ε�Ε�G..                                             G..Ε��ȸΕ��dV�dV�dV�dV�dV�dV�dV�dV�ȸΕ�Ε�Ε�G..                                                T41Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�dV�ȸΕ�Ε�Ε�G..                                                T41Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�ȸΕ�Ε�Ε�G..                                                T41Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�ȸΕ�Ε�Ε�G..                                                T41Ε�Ε�Ε�Ε��dV�dV�dV�dV�dV�dV�ȸΕ�Ε�G..                                                   T41Ε�Ε�Ε�Ε��dV�dV�dV�dV�ȸ�ȸΕ�G..G..                                                      T41Ε�Ε�Ε��dV�dV�dV�ȸ�ȸΕ�G..G..                                                            T41Ε�Ε��dV�dV�ȸ�ȸΕ�G..G..                                                                  T41Ε��dV�ȸ�ȸΕ�G..G..                                                                        T41�ȸ�ȸG..G..G..                                                                                 G..G..                                                            ���������������� �� �� �  �  �  �  �  �  �  �  �  �   �   �  �  �  �  �� �� �� �� ���������������������       �� ���     0              @   �   �      �� ��              	 (       @         �                                                                                                                                    G..G..G..G..G..G..G..G..G..                                                         G..G..�ȸ�ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�G..                                                   G..Ε��ȸ�ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                                                G..�ȸ�ȸ�ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                                             G..�ȸ�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                                          G..Ε��ȸ�ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                                       G..Ε��ȸ�ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                                    G..�dVΕ�����ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                        G..�dVΕ��ȸ����ȸ�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..                  G..G..G..G..�ȸ�ȸ�ȸ�dV�������ȸ�dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..               G..G..�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�dVΕ�����������dVΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε��dVG..            G..�ȸ�ȸ�ȸ����������������ȸ�ȸ�dV�������������dVΕ�Ε�Ε�Ε�Ε�Ε�Ε��dV�ȸG..         G..�ȸ�������������������������ȸ�ȸ�ȸ�dV������������Ε��dV�dV�dV�dV�dV�dV�ȸ�ȸG..         G..�ȸ�������������������������������ȸ�ȸ�ȸ�dVΕ�����������������ȸ�ȸ�ȸ�ȸ�ȸG..         T41�������������������������������������ȸ�ȸ�ȸΕ��dV�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸG..G..            G..����������������������ȸ�ȸ����������������ȸ�ȸ�ȸ�ȸΕ�Ε�Ε��dV�dV�dVG..                  G..����������������ȸ�ȸ�ȸ�ȸ�ȸ�������������������ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�G..                  G..�������������ȸG..G..�dV�ȸ�ȸ�������������������������������ȸ�ȸ�ȸ�ȸG..                     G..�������ȸG..      G..�ȸ�ȸ����������������������������������ȸ�ȸ�ȸG..                        G..G..G..      G..�ȸ�ȸ����������������������������������ȸ�ȸ�ȸG..                                       G..Ε��ȸ�ȸ����������������������������������ȸ�ȸΕ�G..                           G..�ȸ�ȸ�������������������������������������ȸ�ȸG..                           G..G..G..G..�ȸ�ȸ����������������������������������������ȸ�ȸG..                        G..�ȸ�ȸ�ȸ�ȸ����������������������������������������������ȸ�ȸG..                        G..�������������������������������������������������������������ȸΕ�G..                        G..����������������������������������������������������������ȸ�ȸG..                           G..�ȸ�������������������������������������������������������ȸ�ȸG..                              G..����������������������������������ȸ����������������ȸ�ȸG..                                    G..�ȸ�������������������������ȸ����������������ȸ�ȸG..                                          G..G..T41�������������ȸ�ȸ�ȸ�������ȸ�ȸ�ȸG..G..                                                      G..G..G..G..G..G..G..G..G..G..G..G..                                       ���?�� �� �� �� �� �� �� �� �  �  �  �  �  �        ?   ?   ?�  ?�  ?�  ?�  �  �  �  �  ��  �� �� �� �� �       �� ���     0              @   �   �      �� ��                 (       @         �                  G..G..G..G..G..G..G..G..G..G..                                       G..G..G..G..G..G..G..G..�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�dVG..                                       G..����������������������������������ȸ�ȸ�ȸ�ȸ�ȸ�ȸG..                                       G..����������������������������������ȸ�ȸ�ȸ�ȸ�ȸ�ȸG..                                       G..����������������������������������ȸ�ȸ�ȸ�ȸ�ȸ�ȸG..                                       G..�ȸ����������������������������ȸ�ȸ�ȸ�ȸ�ȸ�dVG..                                             G..�dV�ȸ�������������������ȸ�ȸ�ȸΕ�Ε��dV�dVG..                                                G..�dV�ȸ�ȸ�ȸ����������������������ȸΕ�Ε�G..                                             G..�ȸ�ȸ�������������������������������ȸ�ȸΕ�G..                                          G..����������������������������������������ȸ�ȸG..                                       G..�ȸ����������������������������������������ȸ�ȸΕ�G..                                       G..�������������������������������������������ȸ�ȸΕ�G..                                    T41�������������������������������������������ȸ�ȸΕ�G..                                    G..����������������������������������������������ȸ�ȸΕ�G..                                    G..����������������������������������������������ȸ�ȸΕ�G..                                    G..����������������������������������������������ȸ�ȸΕ�G..                                    G..����������������������������������������������ȸ�ȸΕ�G..                                    G..����������������������������������������������ȸ�ȸΕ�G..                                    G..����������������������������������������������ȸ�ȸΕ�G..                                    G..�ȸ�������������������ȸ�������������������ȸ�ȸ�ȸΕ�G..                                       G..�������������������ȸ�ȸ����������������ȸ�ȸΕ�G..                                          G..�ȸ����������������ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸG..                                                G..����������������ȸ�dVΕ�Ε�Ε�Ε�Ε�G..G..                                                   G..�������������ȸ�ȸ�dVΕ�Ε�Ε�G..G..                                                         G..�������������ȸ�ȸ�dVG..G..G..                                                               G..�������������ȸ�ȸG..                                                                        G..�������������ȸ�ȸG..                                                                        G..�������������ȸ�ȸG..                                                                        G..�������������ȸ�ȸG..                                                                        G..�������������ȸG..                                                                              G..�������ȸ�ȸG..                                                                                 G..G..G..G..                                                                          �  �  �  �  �  ?�� ?�� �� �� �� �� �  �  �  �  �  �  �  �  �� �� ?�� ��������?���?���?���?������������       �� ���     0              @   �   �      �� ��               (       @         �                                                            W8/                                                                                    W8/Ε�W8/                                                                              W8/Ε�Ε�Ε�W8/                                                                        W8/Ε��ȸ�ȸ�ȸΕ�W8/                                                                  W8/Ε��ȸ�ȸ�ȸ�ȸ�ȸΕ�W8/                                                            W8/Ε��ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�W8/                                                         W8/Ε��ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�W8/                                                         W8/�ȸ�������ȸ�ȸ�ȸ�ȸ�ȸ�������ȸW8/                                                         W8/W8/W8/W8/�ȸ�ȸ�ȸ�ȸ�ȸW8/W8/W8/W8/                                                            W8/�ȸ�ȸ�ȸW8/                                             W8/W8/W8/               W8/�ȸ�ȸ�ȸW8/               W8/W8/W8/                        W8/Ε�Ε�W8/               W8/���������W8/               W8/Ε�Ε�W8/                  W8/Ε�Ε�Ε�W8/               W8/W8/W8/W8/W8/               W8/Ε�Ε�Ε�W8/            W8/Ε�Ε�Ε�Ε�W8/                        W8/Ε�Ε�Ε�Ε�W8/      W8/Ε�Ε�Ε�Ε�Ε�Ε�W8/W8/W8/      W8/W8/W8/   W8/W8/W8/W8/Ε�Ε�Ε�Ε�Ε�Ε�W8/   W8/Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�̓�S6-   U8/Ε�Ε�Ε�W8/   W8/Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�W8/   Ε��ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ辰='    M1)�ȸ�ȸ�ȸW8/   W8/�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸΕ�   W8/����ȸ�ȸ�ȸ�ȸ�ȸ�ȸ������߷�'   B+$���������W8/   W8/�ȸ�������ȸ�ȸ�ȸ�ȸ�ȸ�ȸ���W8/      W8/����ȸ�ȸ�ȸ�ȸ���W8/W8/U8/L1)      W8/W8/W8/      W8/W8/W8/W8/����ȸ�ȸ�ȸ�ȸ���W8/            W8/����ȸ�ȸ�ȸW8/                              W8/�ȸ�ȸ�ȸ���W8/                  W8/����ȸ�ȸW8/               W8/W8/W8/W8/W8/               W8/�ȸ�ȸ���W8/                        W8/������W8/               W8/�ȸ�ȸ�ȸW8/               W8/������W8/                              W8/W8/W8/               W8/�ȸ�ȸ�ȸW8/               W8/W8/W8/                                                W8/�ȸ�ȸ�ȸW8/                                                            W8/W8/W8/Ε��ȸ�ȸ�ȸΕ�W8/W8/W8/                                                         W8/�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸW8/                                                         W8/�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸW8/                                                            W8/����ȸ�ȸ�ȸ�ȸ�ȸ�ȸ�ȸ���W8/                                                                  W8/����ȸ�ȸ�ȸ�ȸ�ȸ���W8/                                                                        W8/����ȸ�ȸ�ȸ���W8/                                                                              W8/���������W8/                                                                                    W8/Ε�W8/                                             �����?������������������������>?��>��>��>�`            �`��>��>��>��>?�����������������������?����       �� ���     0              @   �   �      �� ��               (       @         �                  G..G..G..G..G..G..G..G..G..G..G..G..G..G..G..G..G..G..                                          G..Ε��ȸ�ȸ�ȸ�������������������ȸ�ȸ�ȸΕ�Ε��dVG..                                          G..Ε��ȸ�ȸ�ȸ�������������������ȸ�ȸ�ȸΕ�Ε��dVG..                                             G..W8/�dV�dV�dV�dV�dV�dV�dV�dV�dVW8/W8/W8/W8/G..                                                G..�ȸ�ȸ�ȸ�ȸ�������������ȸ�ȸΕ�Ε��dV�dVG..                                                G..�dVΕ�Ε��dV�dV�dV�dV�dV�dVW8/W8/W8/W8/W8/G..                                                G..�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε��ȸG..                                                G..���Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε����G..                                                G..���Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε��ȸ���G..                                                G..�ȸ���Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�����ȸG..                                                   G..���Ε�Ε�Ε��ȸ�ȸ�ȸΕ�Ε�Ε��ȸ���G..                                                      G..�ȸ����ȸ�ȸ�ȸ�ȸ�ȸΕ�Ε��ȸ����ȸG..                                                         G..����ȸ�ȸ�������ȸΕ�Ε��ȸ���G..                                                               G..����ȸ�������ȸΕ��ȸ���G..                                                                     G..����ȸ�ȸ�ȸ�ȸ���G..                                                                           G..����ȸ�ȸ���G..                                                                           G..����ȸ�ȸ���G..                                                                     G..����ȸ�ȸ�ȸ�ȸ���G..                                                               G..����ȸ�ȸ�ȸ�ȸΕ��ȸ���G..                                                         G..����ȸ�ȸ�ȸ�ȸ�ȸΕ��ȸ�ȸ���G..                                                      G..�ȸ����ȸ�ȸ�ȸ�ȸ�ȸΕ��ȸΕ�����ȸG..                                                   G..����ȸ�ȸ�ȸ����ȸ�ȸΕ�Ε�Ε�Ε����G..                                                G..�ȸ����ȸ�ȸ�������ȸ�ȸΕ�Ε�Ε�Ε����Ε�G..                                                G..����ȸ�ȸ�ȸ�������ȸ�ȸΕ�Ε�Ε�Ε�Ε����G..                                                G..����ȸ�ȸ�ȸ�������ȸΕ��dV�dV�dV�dVΕ����G..                                                G..�ȸΕ�Ε�Ε�Ε�Ε�Ε�Ε��dV�dV�dV�dVΕ����G..                                                G..�dVΕ�Ε��dV�dV�dV�dV�dV�dV�dV�dV�dV�dV�dVG..                                                G..�ȸ�ȸ�ȸ�ȸ�������������ȸ�ȸΕ�Ε��dV�dVG..                                             G..Ε�Ε�Ε�Ε��ȸ�ȸ�ȸ�ȸ�ȸΕ��dV�dV�dV�dVG..                                          G..Ε��ȸ�ȸ�ȸ�������������������ȸ�ȸ�ȸΕ�Ε��dVG..                                          G..Ε��ȸ�ȸ�ȸ�������������������ȸ�ȸ�ȸΕ�Ε��dVG..                                          G..G..G..G..G..T41T41T41T41T41T41G..G..G..G..G..G..G..                                            ?�  ?�  ?�� �� �� �� �� �� �� �� ��� ������������������������ ��� ��� �� �� �� �� �� �� �  ?�  ?�  ?�  ?�       �� ���     0              @   �   �      �� ��	               (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 R9R9                                                      R9R9                           R9���R9                      R  R  R                         R9���R9                     R9������R9                   R ��������� R                      R9����ƄR9               R9���������R9R9R9R9R9R9 R �  �  �  � ��� R R9R9R9R9R9R9R9���������R9         R9�������� �� ��������������� R ��� � �  �  �  � ��� R �����������������������1��B���R9   R9�������� �� �� �� �� �� �� ��  R ���� ����  �  � ��� R ����������������1��Bޔc���R9   R9Ƅ1�� �� �Ƅ1Ƅ1Ƅ1ƌ1ƌ9 R �������������  � ��� R ��s��s��s��s��s��s����1�R���R9         R9Ƅ1����R9R9R9R9R9R9 R �������  � �  R R9R9R9R9R9R9R9�����B���R9               R9Ƅ1���R9                   R ��������� R                      R9������R9                     R9���R9                      R  R  R                         R9���R9                           R9R9                                                      R9R9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               �������������������������������������������������?��  �      �  �  ��?����������������������������������������������������       �� ���     0              @   �  	 �      �� ��
               (       @         �                                                               R)                                                                                          R)���R)                                                                                    R)�����c���R)                                                                              R)����� �� ��c���R)                                                                        R)����� �� �� �� ��c���R)                                                                  R)�������������� �� ���������R)                                                               R)R)R)R)����� ��kR)R)R)R)                                                                        R)����� ��kR)                                                                                 R)����� ��kR)                                                                                 R)����� ��kR)                                                                                 R)����� ��kR)                                                                                 R)����� ��kR)                                                                                 R) R  R  R R)                                                                                  R ��������� R                                                                                R �  �  �  � ��� R                                                                          R ��� � �  �  �  � ��� R                                                                       R ���� ����  �  � ��� R                                                                       R �������������  � ��� R                                                                          R �������  � �  R                                                                                R ��������� R                                                                                  R) R  R  R R)                                                                                 R)���� �s9R)                                                                                 R)���� �s1R)                                                                                 R)���� �s1R)                                                                                 R)���� �s1R)                                                                        R)R)R)R)���� �k1R)R)R)R)                                                               R)���������� � �{���������R)                                                                  R)������� � � �{�k1R)                                                                        R)������� � �k1R)                                                                              R)�������k1R)                                                                                    R)���R)                                                                                          R)                                                ���������?���������������?���?���?���?���?���?���?������������������?���?���?���?���?���?���������������?��������       �� ���     0              @   �  
 �      �� ��               (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               c9c9c9c9c9c9c9c1                                                                        c9������������������c1                                                                           c9�����������cc9                                                                              R)����� ����cc9                                                                           R)����� �� ����cc9                                                                        R)����� ��R)�����cc9                                                             R  R  R R)����� ��k9   c9���c9                                                          R ��������� R �� ��k9         c9c9                                                       R �  �  �  � ��� R k9                                                                      R ��� � �  �  �  � ��� R                                                                       R ���� ����  �  � ��� R                                                                       R �������������  � ��� R                                                                      R) R �������  � �  R                                                                      R)� ��  R ��������� R                                                                      R)� � �{R) R  R  R                                                          R)R)      R)� � �{R)                                                                     R)���R)R)� � �{R)                                                                        R)���� � � �{R)                                                                           R)���� � � R)                                                                              R)�����R��R��R��RR)                                                                           R)������������������R)                                                                        R)R)R)R)R)R)R)R)                                                                                                                                                                     ������������������������������������������������������������9����� �� �� �� ���������?���������������������������       �� ���     0              @   �   �      �� ��               (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  c1c9c9c9c9c9c9c9c9                                                                     c1������������������c9                                                                        c9��c���������c9                                                                           c9��c���� �� �� k9                                                                           c9��c���� �� �� ���k9                                                                        c9��c��������� �� ���k9                                                                     c9���c9k9k9���� �� ���k9                                                                  c9c9         k9���� �� ���k9                                                               c9               k9���� �� ���c9 R  R  R                                                                         k9���� ��  R ��������� R                                                                         k9�� R ��� �  �  � �  R                                                                          R ��� �  �  � �  � ��� R                                                                       R ��� �  � � ���� ��� R                                                                       R ��� � � ��������֔�� R                                                                          R �  � � ��֔�� R R)                                                                            R ��������� R � ���R)                                                                            R  R  R ��� � ���R)                                                                                 R)�{� � ���R)         R)R)                                                                  R)�{� � ���R)   R)���R)                                                                     R)�{� � ���R)� ���R)                                                                        R)�{� � � � ���R)                                                                           R)�{� � � ���R)                                                                           R)�{� � � ���R)                                                                        R)�{��R��R��R��R���R)                                                                     R)���������������������R)                                                                     R)R)R)R)R)R)R)R)R)                                                                                                                  �������������������� �� ��������� ��� �� ?��8��|��� ��� ���?���?���?���?���������?��?���?���?���?���?���?���?���?����       �� ���     0              @   �   �      �� ��              	 (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     �������������������������ȸ                                                                     G..G..G..����ȸG..G..G..G..                                                                              ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                                          ����ȸ                                                                              G..����������������������ȸG..                                                                     G..G..G..G..G..G..G..G..                                                                     �������������������������������������������������?�� �� ���?����������������������������������������������������� ?�� ?�����       �� ���     0              @   �   �      �� ��               (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                     G..G..G..G..G..G..                                                                        G..G..�dV�dV�dV�dV�dV�dVG..G..                                                               G..�dV�dV�ȸ�������������ȸ�dV�dVG..                                                         G..�dV�ȸ����������eU�PC����������ȸ�dVG..                                                   G..�dV�ȸ�������������eU�PC�������������ȸ�dVG..                                                G..�ȸ�������������������������������������ȸG..                                             G..�dV�ȸ����������������eU�PC����������������ȸ�dVG..                                          G..�ȸ�������������������eU�PC�������������������ȸG..                                          G..�ȸ����������������eU�eU�eU�PC����������������ȸG..                                          G..�ȸ����������������eU�eU�eU�PC����������������ȸG..                                          G..�ȸ����������������eU�eU�eU�PC����������������ȸG..                                          G..�dV�ȸ�������������eU�eU�eU�PC�������������ȸ�dVG..                              G..G..         G..�ȸ�������������eU��eU�PC�������������ȸG..                                 G..�ȸG..      G..�dV�������������eU��eU�PC����������ȸ�dVG..                              G..�dV����ȸG..G..�dV����dV�ȸ����������eU�PC����������ȸ�dVG..                                 G..�ȸ�������ȸ�dV����dVG..�dV�ȸ�ȸ�������������ȸ�ȸ�dVG..                                 G..�dV����������������dVG..   G..G..�dV�ȸ�ȸ�ȸ�ȸ�dVG..G..                                    G..�ȸ����������������ȸG..         G..G..G..G..G..G..                                       G..�dV����������������������ȸG..                                                               G..�ȸ�������������������������ȸG..                                                         G..�dV����������������������ȸ�ȸG..G..                                                         G..�ȸ����������������ȸ�ȸG..G..                                                            G..�dV�������������ȸ�ȸG..G..                                                                  G..�ȸ�������ȸ�ȸG..G..                                                                     G..�ȸ����ȸ�ȸG..G..                                                                           G..�ȸ�ȸG..G..                                                                              G..�ȸG..G..                                                                                    G..G..                                                                                          ���������������������� �� ?�� �� �� �� �� �� �� �� �� �p �0 �  �  ?� ������� ��� ���������?�������������?���       �� ���     0              @   �   �      �� ��               (       @         �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             G..G..G..G..G..G..G..G..                                                                  G..G..Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..G..                                                      G..G..Ε�Ε�Ε�������������������Ε�Ε�Ε�G..G..                                             G..Ε�Ε�Ε�������������������������������Ε�Ε�Ε�G..                                       G..Ε�Ε�������������������������������������������Ε�Ε�G..                                 G..Ε�Ε�������������������������������������������������Ε�Ε�G..                              G..Ε����������iN=iN=iN=������������������iN=iN=iN=���������Ε�G..                           G..Ε�Ε�������iN=iN=iN=iN=iN=������������iN=iN=iN=iN=iN=������Ε�Ε�G..                        G..Ε������������{iN=iN=iN=iN=iN=������iN=iN=iN=iN=iN=iN=���������Ε�G..                     G..Ε�Ε���������������{iN=iN=iN=iN=iN=iN=iN=iN=iN=iN=iN=������������Ε�Ε�G..                  G..Ε���������������������{iN=iN=iN=iN=iN=iN=iN=iN=iN=������������������Ε�G..                  G..Ε������������������������{iN=iN=iN=iN=iN=iN=iN=���������������������Ε�G..                  G..Ε�������������������������iN=iN=iN=iN=iN=iN=������������������������Ε�G..                  G..Ε�������������������������iN=iN=iN=iN=iN=iN=������������������������Ε�G..                  G..Ε����������������������iN=iN=iN=iN=iN=iN=iN=iN=���������������������Ε�G..                  G..Ε�������������������iN=iN=iN=iN=iN=iN=iN=iN=iN=iN=������������������Ε�G..                  G..Ε�Ε�������������iN=iN=iN=iN=iN=iN=iN=iN=iN=iN=iN=iN=������������Ε�Ε�G..                     G..Ε����������iN=iN=iN=iN=iN=iN=��������{iN=iN=iN=iN=iN=���������Ε�G..                        G..Ε�Ε���������{iN=iN=iN=iN=��������������{iN=iN=iN=iN=������Ε�Ε�G..                           G..Ε������������{iN=iN=��������������������{iN=iN=���������Ε�G..                              G..Ε�Ε�������������������������������������������������Ε�Ε�G..                                 G..Ε�Ε�������������������������������������������Ε�Ε�G..                                       G..Ε�Ε�Ε�������������������������������Ε�Ε�Ε�G..                                             G..G..Ε�Ε�Ε�������������������Ε�Ε�Ε�G..G..                                                      G..G..Ε�Ε�Ε�Ε�Ε�Ε�Ε�Ε�G..G..                                                                  G..G..G..G..G..G..G..G..                                             ���������������������������� �� �� �� ��  ��  ��  �     ?   ?   ?   ?   ?   ?   ?   ?�  �  �  ��  �� �� �� �� ����       �� ���     0              @   �   �      �� ��              	 (       @         �                                                                                                                                                                                                                                             B))B))                                                                                 B))���Δ�B))B))                                                                           B))���Δ�Δ�Δ�B))B))                                                                     B))���Δ��ν�ν�cR�cRB))B))                                                   B))���Δ��ν�ν�ν�ν�cR�cRB))B))                                          B))B))B))B))B))���Δ��ν�ν�ν�ν�ν�ν�cR�cRB))B))B))                                          B))Δ�Δ�Δ�Δ����Δ��ν�ν�ν�ν�ν�ν�ν�ν�cR�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�cR�cR�cR�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�cR�νΔ��ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�cRΔ�Δ��ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR���Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR�cR�cR���cR�ν�ν�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR�cR�cR�cR�cR���cR�ν�ν�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR�cR�cR�cR�cR�cR�cR���cR�ν�ν�ν�cRB))                                          B))Δ��cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR���cR�ν�cRB))                                          B))Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ��cR�cRB))                                          B))B))B))B))B))B))B))B))B))B))B))B))B))B))B))B))B))B))                                                                                                                     ��������������?��������  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  ����       �� ���     0              @   �   �      �� ��                 (       @         �                                                                                                                                                               �cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR                  �cRΔ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ��cR                  �cR�ν�cR�cR�cR�cRlA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2Δ��cR                  �cR�ν�cRΔ��ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�νΔ�lA2Δ��cR                  �cR�ν�cRΔ�Δ��ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�νΔ�Δ�lA2Δ��cR                  �cR�ν�cRΔ�Δ��cRΔ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ��cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRΔ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ��cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2�cR�cR�cR�cR�cR�cR�cR�cRlA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2�cR�cR�cR�cR�cR�cRlA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRΔ�Δ��cR�cRlA2lA2lA2lA2�cR�cRΔ�Δ�lA2Δ��cR                  Δ��ν�cRlA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2lA2Δ��cR                  Δ��ν�cRΔ��ν�ν�ν�ν�ν�ν�ν�νΔ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�lA2Δ��cR                  Δ��ν�cRΔ��ν�ν�ν�ν�ν�ν�ν�ν�ν�νΔ�Δ�Δ�Δ�Δ�Δ�Δ�lA2Δ��cR                  Δ��ν�cRΔ��������ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�νΔ�Δ�Δ�Δ��cRΔ��cR                  Δ��ν�cRΔ��������������ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�νΔ�Δ��cRΔ��cR                  Δ��ν�cRΔ�Δ�Δ��������������ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�cRΔ��cR                  Δ��ν�cRΔ�Δ�Δ�Δ�Δ��������������ν�ν�ν�ν�ν�ν�ν�ν�ν�cRΔ��cR                  Δ��ν�cRΔ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ��cRΔ��cR                  Δ��ν�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cR�cRΔ��cR                  Δ��������������������������ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�ν�νΔ��cR                  Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ�Δ��cR�cR�cR�cR�cR�cR�cR                                                                                                                           �����  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  ����       �� ���     0              @   �   �      �� ��                 (       @         �                                                                                                                                                                                    B))B))B))B))B))B))B))B))B))B))B))B))                                                      B))����ν�ν�ν�ν�ν�ν�νΔ�Δ�B))            B))B))                                    B))B))B))����νΔ����B))B))B))            B))�νΔ�B))B))                                       B))�νΔ�B))                     B))�ν�ν�cRΔ�Δ�B))B))                                    B))�νΔ�B))                  B))�ν�ν�cRΔ�Δ�Δ�Δ�B))                                 B))���Δ�B))                  B))�ν�ν����νΔ�Δ�Δ�Δ�Δ�B))                              B))���Δ�B))B))�ν����������ν�cRΔ�Δ�Δ�Δ�B))                           B))���Δ�B))B))B))B))B))B))B))�νΔ��������������ν�cRΔ�Δ�Δ�Δ�B))                           B))���B))B))�ν�ν�ν�ν�ν�ν�νΔ�����������������ν�cRΔ�Δ�Δ�B))                        B))B))�ν�ν�ν�������������ν�ν�νΔ�����������������ν�cRΔ�Δ�Δ�B))                     B))�ν�������������������������ν�ν�νΔ��������������ν�ν�cRΔ�Δ�B))                  B))�ν�������������������������������ν�ν�νΔ��������������ν�ν�cR�cRΔ�B))               R11�������������������������������������ν�ν�ν�cR�ν����������ν�ν�ν�cRB))               B))����������������������ν�ν����������������ν�ν�ν�cR�ν�������ν�ν�νB))                  B))����������������ν�ν�ν�ν�ν�������������ν�ν�ν�ν�cR�cR�ν�νB))B))                  B))�������������νB))B))�cR�ν�ν����������������ν�ν�ν�ν�νB))B))                        B))Δ�B))�������νB))�νΔ�B))�ν�ν�������������������ν�ν�νB))                              B))Δ����B))B))B))����νΔ�B))�ν�ν����������������������ν�νB))                              B))Δ�����������������νB))Δ��ν�ν����������������������ν�νB))                              B))�ν����������������νB))�ν�ν�������������������������ν�νB))                           ������B))�ν�ν����������������������������ν�νB))                        �ν�ν�ν�ν�ν�������������������������������������νB))                           �ν�������������������������������������������������������νΔ�B))                           B))�ν����������������������������������������������������ν�νB))                              B))�ν�������������������������������������������������ν�νB))                                 B))�ν�������������������������ν�������������������ν�νB))                                       B))�ν�ν����������ν�ν�ν�������������ν�ν�νB))B))                                             B))B))�ν�ν�ν�ν�ν�ν�ν�ν�ν�νB))B))B))                                                         B))B))B))B))B))B))B))B))B))B))                                                                                                                                                   ����������������?�?�? �? �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  ��  �� �� �� �� �� ?��������       �� ���     0              @   �   �      �� ��                 (       @         �                                                                                                                                                                                 �5K�5K�5K                                                                                 �5K���퍜�5K�5K                                                                              퍜���������                                                                           {0A��������κ\k                                                                           �5K퍜퍜���퍜                                                                           {0A퍜퍜퍜�\k                                                                           �\k퍜퍜퍜                                             �GX;;                     {0A퍜퍜퍜�\k                                          �GX���㟖㟖;               �m}�m}퍜�m}                                             �GX���ޅ�㟖㟖㟖      o4Ao4A�m}�m}�m}                                          �GX݅����薚�in�in㟖㟖㟖o4Ao4Ao4Ao4Ao4A                                          �GX���쮦薚ޅ��in�in�in�in㟖�GXZ$Z$Z$o4Ao4A                                          �GX݅�����Ƚ薚薚ޅ�ޅ�ޅ��in�inZ$Z$Z$Z$                                          f7^݅�������節薚ޅ�ޅ�ޅ�ޅ��in�GX�`r�`rZ$                              �GX݅����������節節薚ޅ�ޅ�ޅ��GX�GX�vz�`r�`r�`r�`r㟖㟖㟖                        f7^݅�������������節節薚ޅ�ޅ��GX㟖薚薚�vz�`r�`r�GX�in�in�in㟖㟖                  f7^�������Ƚ�Ƚ���節節薚ޅ�ޅ��in薚薚薚薚�vz�GX薚ޅ�ޅ��in�in㟖㟖㟖         f7^݅��������Ƚ�Ƚ������節節薚�in節節節薚薚�vz�GX薚薚ޅ�ޅ�ޅ�ޅ��in㟖㟖         f7^����������Ƚ�Ƚ���������節節���節節節節薚薚���節節薚ޅ�ޅ�ޅ��in㟖         f7^݅��������������Ƚ�Ƚ���������������節節節節薚薚������節薚ޅ�ޅ�ޅ��in㟖         f7^f7^݅��������Ƚ�������Ƚ�Ƚ����vz���������節節薚薚���節節薚薚ޅ�ޅ��in                  f7^f7^݅��������������������������������������vz������節節節薚ޅ��in㟖                        f7^f7^݅�����������ev����������������������Ƚ�Ƚ���節節薚ޅ��in㟖                              f7^f7^݅��ev�ev�GX�GX���������݅��������Ƚ������節薚ޅ�㟖                                       f7^�GX�GX      �GX�GX݅�����������Ƚ�Ƚ���節薚薚㟖                                                            f7^݅�������������������薚薚�in                                                            f7^f7^݅�݅����������������薚                                                                     f7^f7^�GX݅����������in                                                                              �GX;݅�݅�                                                                                       ;;;                                                                                                                  ����������?���?���?�����������?�������� �� �� ��  �  �  �  �  �  �  �  �  �  �  �� �� �� ������?���?����       �� ���     0              @   �   h      �� ��             (   0   `         �                        �  �   �� �   � � ��  ��� ���   �  �   �� �   � � ��  ���                                               w  ��          vggx    w3����;       gx��wW� s{w  ��;��    �������Ww7��  ������  �0x�ffGh��W{    ����;{ ;:�g  tw��p    ;;;;� ���p  w7ux�X    ��;;; ;� wwp u�u     �;7��   ��73fh X�P     ��7�   �7� vdp w�W      ��x��s�w   �` u���         �;�z�   vg�x�U       sw6z   �vllg�X�X      �;;:zg  v�ffg����]    w�� � jffffo����up  ���     zzf�&vv��w�����x  ����  �&'&h���t�W��P   	��37�6������fvt��P �xx���7:wz��x�h�F�u�P	��������7?����g�df�O�Wy����{x�������h�f�f�Vx�Ww��y�y����8�'�r�s�vf�X�P��������8�w�v�����Fd��u��8y99�;;������h�(��W��p	�����������/�(�v����u��y�����;?�8�(�r��h���G�	��9?����x�8�z����&w�f� ��������s������fffǀ ����w�x��������&ff`   ����������x��wbf&h    y�y����s����7�&�&�`     	��������;:�:v&j��     ��y7w9�{xww��         ��������               ������{0                	������0 �����           ��yy�����3�{���          ���80��3s�3{����          �80�3373333����         �����s�7;77;#;�           ��33�#;33�s{�           �73�73s��3;�           ����3;3{73;;            ���;;3;3s;�               ����3�;;�                  ������                     �� ������  ������  ����?�  �?�   ��    ��  ?  ��>   ��| ?  ���p?  �� 8  ��  � ?  ��?  ���   ���   ��    ��    @�    � `    �      �                                     �      �      �      �      �      �    ?  �   �  �   �  � �  � ���  � ���  �  �  �  �  ��    ���    ���    ���     ���     ���     ����    ����    �����  ������  �      �� ��             (       @                                  �  �   �� �   � � ��  ��� ���   �  �   �� �   � � ��  ���                         wx   �p��0    h��wp�s����� ��fg��s� ��;0�x` u�P   �3��8� �w�x�   �;0  �ssfp�P   ����8p hx      �7� �|X�p   s:zpfff����  ��  �jffh���Pp���f'��vW�P  ��;8�&����FǏX	x������x�fVWx��w�������odl}��9�����h��o�e�Wx��9���?s�ow�w�px����{x�(���@	�������&wl ����������ff` 	����{����rrfw   ���s�;7�jfv    ���s�� �x       �����           	x��� �;��       	����3�;���      3��s333;;�       �3�;7;s�       �s33s�3�        ���{3�s�          �����             � ��������� A�r �`x�`��|��x���x���� � �   �                 �  �  �  �  ?�������� �� ��  ��  ��  ��� ����(      �� ��             (                �                         �  �   �� �   � � ��  ��� ���   �  �   �� �   � � ��  ���         ;  xxw�;�� w�  ���x�  �xf�p ���fx����7��l�x�����f������x��������f����x�` �x�     �����    �73;{    �;s;      ����  �  ��  �I  ��  �   �              �  ��  �  �   �   ��  �      �� ��             (   0   `          	                    %%, Tz tw V|& zu( zx y8k ~Z "xN }II _tQ ouW wJv tst �?> �O
 �l	 �L0 �d+ �y) �o8 �p5 �v0 �:S �.e �'w �9u �LP �gC �vK �kK �Gd �Cg �R` �Iv �Mu �X} �pq �bg :� 4�$ =�2 O� g� D� O�/ k�) i�3 u�6 L�- z�> �_ 9�N �r 9�w .�p V�M o�B x�C k�F }�P i�T z�R Q�P l�Z S�g p�j M�l s�h _�| t�p �� ��+ ��I ��L ��Y ��^ ��T ��_ ��a ��b ��~ ��x ��u ��i ��x ��v z� y)� >z� G{� @^� @z� Gi� � "� /� +,� 6� H� 4P� 
n� /l� P� 0H� l� (}� MO� Ip� cf� SR� d_� Ps� po� �� �-� �9� �W� �k� �l� �A� �K� �s� �n� �y� �� ;�� �� *�� .�� �� -�� H�� P�� q�� H�� Y�� X�� I�� _�� h�� b�� e�� f�� u�� A�� u�� �� ̩ ɺ Ҵ &ϲ nƅ Zͬ qϣ �� )�� �� .�� 	�� /�� �� U�� o�� R�� r�� M�� R�� h�� �� �� �� �� %�� 4�� 9�� =�� �� 1�� V�� a�� d�� i�� V�� z�� N�� h�� z�� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� Ǡ� ��� Ē� ��� ȼ� �ƅ �զ �ŵ �ǻ ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ľ� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                                                                             ��    ���                     LP�        ��]]�  ���������              1J�������% "�   �]]]]�    ����������        �  <������������$wZZ]]��     �����������     ��� E��S"����{]�        ������������   ����D��/3     �

����Yx          �����������   ����D�TM     ��]�v���Y|         �����������   ��� A�<   ����   "#���X          ����������       E�A�Z]�B�   '��{s           ��������       B�>��   LI   !w��Yy            ���� �����������9C      U   '���X|                   ��� GC�A      UK V"%��tsu               �Z855@@M      WNIHR�x#���s|            䐈Z��885--2    3,,,,��������Xz         ����  ��    F*2  2++++,,H���������vsz     �����           2222++-++/?JH����&&�����s} ����    � ������    @*--+.++.������������Xs        ����������  �5*--���+M����������Ys    �qgg�������꓆8�85�>(���.A���:���%��s  oid��������������88D��2E��T.��S,=��"��vXzpd�������ᑦ�������88���)���.���//����vzon��磣�������������8���)T��C0��������%t pn��m�gjjgΝ������������9*���)���Q��x��#zrl��\�mjhjff���������8���)���?.������S'���x  b��odhhjj����ㄪ����7���@.���(���?/��������R�  b��mchhj�������������8���)���9.���+0�������!}  b���cihd�������떀���8���E9���C���Q,:����   on��cchm��������������7���B��������+,'�    rb��lcc��������������������������Q,,,       b���ace�����Ο�������������(>�>++,,HH�        pl��lac����������������8D��*+(+(+++,            `���ece�����✂�������88855---+,+O V            �`����ddmߦmfm����� ܙ�GG@MM W                   rb����mggm�����                                rbn�������������                                  i`n�������f��   ���������                       �idimgmgjjj��  ����~~����������                     ����jjk�� �����~����6����������                     �k��΋ ���~~	�~64��~~��������                   ��� �����~~6�~	6~��666������                       �����466�6	~~�~6~6�~4~~���                       ����64��	6	~�~4���6~~~���                       ��������666~�4~6��66~~���                         �����������~6��~		~~���                              ��������~��~������                                    �����������                                           ���   ������  ������  ����?�  �?�   ��    ��  ?  ��>   ��| ?  ���p?  �� 8  ��  � ?  ��?  ���   ���   ��    ��    @�    � `    �      �                                     �      �      �      �      �      �    ?  �   �  �   �  � �  � ���  � ���  �  �  �  �  ��    ���    ���    ���     ���     ���     ����    ����    �����  ������  �      �� ��             (       @                              T{ g~  |z  p~! |)v !{S KKQ sVK duB �M �\ �V �H �R �Q �h �j �a �@" �H# �Q" �F4 �Z3 �e+ �p- �v4 �d/ �:F �)a �7e �=f �CC �C^ �NV �XT �dA �yQ �Fg �Bp �Wx �jv =�	 8�/ =�: M� \�  J� W� J� I� R� f�  A� K�. `�$ h�1 A�6 k�  3�X 8�] �w 7�s *�i ;�h ;�~ -�s D�I [�N Z�P [�P x�@ b�G x�J n�Y �] ^�G N�c K�u u�b d�v K�a Q�d l�k u�c ��E ��V ��Q ��Y ��W ��e ��g ��g ��s ��l ��i ��~ ��~ ��} ��o ��z ��| ��i ��r ��w |� }$� 3\� Wd� Az� )� /3� 6� Y� 'R� q� 1n� P� k� RS� Vp� jj� ML� st� �	� �;� � � �8� �I� �M� �y� �R� �`� �j� �� 9�� �� *�� '�� �� 3�� )�� 1�� �� �� �� �� ��  �� 4�� "�� 4�� 7�� P�� J�� f�� T�� B�� j�� y�� E�� |�� n�� x�� ʫ ϯ ĺ ]ֵ û �� ,�� ��  �� 5�� �� ?�� O�� l�� K�� j�� }�� E�� _�� `�� �� �� "�� "�� 0�� �� ,�� A�� H�� ^�� B�� p�� g�� |�� T�� c�� {�� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� �ɂ �б �ã �­ �ȷ �ǻ ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ¸� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                  �                XV\�      �mm  ������         G�����&� �mmm�  ��������   � [�\$����l��    ĸ������  ä�Q�8    P(��j       �������  ���ed  �	�� !��j       ������     �d�m�E_  ��~        »���� �N�M    fg ʀ���            �A�� TT    Y
^"��i�        㜌�<,5L  �:4������     ��      9L 300.�������|  ��  � ����  R5311/c��������i     �s�������<+5��*�������j� zt���������B@�D��H��.��
 )�}�z�����԰�����?��9��O�[I�)���z��kqv����������6��6����
��'�z��xqvvs������>��F��H��K��%a�� {��puu����妨����+��6��7]����#  y�nuq�����������S�����4\Z   o�ypt������������������.4    z��nr������������J6J-04Ub      o��n����������B;C5/30WW        �w��rrxtt���  �hhh               {w��������                       nw���説�  �������                ���vv�� ������=�������              �����Ʈ==�=��=�����                ����=����=��=���               ���=���=�������                ƽ������=��==��                     Ǿ���������                           Ǿ�  ��������� A�r �`x�`��|��x���x���� � �   �                 �  �  �  �  ?�������� �� ��  ��  ��  ��� ����h      �� ��             (                                     �Q �J �X �B: �y8 �tl L� Y� f� b� Q�) �~ I�^ b�G l�\ H�~ ��) ��3 ��E ��\ ��a ��} ��~ 5N� "P� ]� xy� }z� �I� �C� �v� �n� �y� �� �� �� �� �� �� �� �� �� (�� s�� m�� E�� L�� X�� ļ ѱ $�� |Ħ qǷ pɱ �� :�� .�� "�� \�� [�� z�� |�� q�� m�� t�� s�� {�� �� ��  �� :�� 3�� �� �� �� �� �� <�� =�� O�� Y�� v�� r�� f�� w�� x�� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� Ĭ� ¨� Ļ� �ě �̝ �Ň ��� �Ư �Ԭ �ô �ɪ �³ ��� ��� ��� ��� ��� ��� ��� ��� ��� Ĵ� ξ� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���                                                                                                                                                                                                                                                                                                                                                                                             ���                  EEH    bcZfY0h  D1FQ 2]  ,Wi    G+R  [-  �!     �.o pXeg   yx� s
mkl�  ~C��6�u���?;9�r�_a�d�=<�3�r\�`^�v�j|����t����	  z��/�54n    }zw>��            BA87 K*:PU         @SI$%$)&O        M*('$'"L            TNJV��  �  ��  �I  ��  �   �              �  ��  �  �   �   ��  �      �� ��             (       @         �                                                                                                         Bw�@y�   �� �� ��������                              `�Tb�eq hjjfqm�yJ�z?         Tx�@z�@z�@z�Ax������� �� �� �� �� ��Ѿ            $×;��H�@p�5������������÷��y��=`�=2or?z�@z�@z�@z�@z�Io��� ��ü�� �� �� �� �� ��      Ǩʦͫ$�s�c��֗�l�u3�b'�dA��������񬖵|)vWd�=|�?z�Wu�          �������� �� �� �� ��ʼ   ͪͪέ=�U���T�W�`�0V�=L�NWujsVK�^q������})��Iu               �� ���� ���� �� �� ��
ǹ   ͪͪ
ͦz�s��wP�IS��?y�A|�duBA|�={��j=�:W������z��=w               �� �� ����)������ĵ   ����;�}��y}�s@{�@y�@{�R�H�h�V�f�zN�_(�3a��ۼ����_�               ���� ������8��@y�@x�Aw�@y�Aw�I�s�ǷG�]G�ae�@Y�b��o�H�a   �A4�Q����M����[�                           #��.��1��1�x9��;�~;�dS�@a�IK�]�2\�j�w{ �O�Q�L�<E�)a������{���                  (��.��Ax�>{�3��*��5�_=�:B�B�    P�DP�V� g� z} �n �[ �Q"��������ݬ������8��#��T�      <��;��@z�Az�>y�>����*��)��,��/��>�2@�+E�6I�N� T� _� g~ }u �a������������������������<�Ey�@z�@|�G��M��n���������Ʈ=��   8�NA�F�I�J�N� ��o��Ծ²����������@"�<A���������{��"�R}�X��>M�6g�V�y�%��4��4��'����ŕ'��7�W9�0<�������?��������̿�������R�J�E6�8Lº����~!���/0�+�$W�l�Һ�������������������䀷�+�t;�h���[�N�ã���`�E������U|������[�N�H#�CC�o����;���ᛧ������������ф��C��J��n�����������*�i���˻M�9����ȱu�b�����hx�J����p-�X �K�F2�fn����I����������3\�]�e�Q��Y�� ����¬������d��������A�3�̻���L�*������T{��彾��^�P�F�������Bp��Ἷܶ��Qn�)d�d�k�t�E��%��¿��������7�s������[�P������d�I�������]����¸�yQ��~�����Չ/`�?�盝����7�O�\�\�������������� ɵû���N��������8�/������K�'�ʸ���`�$��s������������XT�3^�<�4.�jj���� 8�G�V����������������7��E��������O��������l�k�����ؼʹ������a� p~!��g��e�Q�C0�-~   GD�1.����]g�<�?f����������������j��E��������c������������������������­Y� m� | �j�L"�9~�wq      ᵸ����)�"I����������BCJUSXB�Ɂ�����������������������m�\S�*o�VM�V� d��i�T5�Zg            ??�1.�����0�l���������������������� ����C��/�r3�XD�IA�F�R� N� xs i�jB                     -*�SS�����,Q�&T�U}�3o�!o����������2��B�jC�`@�+C�-H�S�.X�Hg�Bp�=h�U                           P[�(�><�����������߽�������������F��   @��*��)��)��                                             iv�,O� �QTɜ�������ڟ��=� ����;���� �� ������ �� �� ��������                                 S{�#e�W�a�o�l�k�	{�!��:�� �� ��	���������{���� �� �� �� �� ������                                 ,����s�+�E��:�� �����}�o�� }W�w�����|������������                                 E�� ��"���� �� ��������
��"zQ�������j�����{���� ��                                          �� �� �����~����!|V!zS
���|���������� �� ��                                             �� �� �� ����������
���y����!{R�l�~ �� ��                                                   	�������� �� �� �� ��������	���� �� ��                                                                     	�������� �� �� ����������� � x   ` �  �  �  �  ��  �  �                                    �  �  �  ���  ?�  ��  ��  ��  ��  ��� ��� h      �� ��             (                 @                  ��)��.��                    m�O!|�5V�|BM�~\    ew�	Dw�s@y�[��w��� ��� ���н&ʭǠdI�gq�����������������[w�Du��Ex��Pp�(��*Ϳ�ļ� ���Ͼ�ªSͪ腳��S�?bN�igR{d�pfg������[��~a�        ȾDͿ����"���/��I6��_����C��T�Ow�m��b!��VLwĴ���3���f�        ��(��60���0���=�T�G�H�S�.n]��z{��S����Თ�������;�U>|�J?��`7z��%�É���(��7>�d�C�"�J��b����a�Ļ��Ĭ��¨���������;V�QAhٚn����������dū�1�n�l�\�������}��ɪ������Q��B:��������ij�����q���\���.��������Ư����������������������y8��J�ξ���-��b^��z���]��[�������$��������������������������������³������7u�EBס����"P�������������������ô�����������������f����3��F;��bzII�@����5N����������L�������qǷ�|Ħ��ě�Q�)�W��l؆j8`�s`        :@ی��������|�����������C��:;��_7�wcM�f2X�_Q�l                    @Y�ZFn��c���8������!��j����������ϸ�ݎ��`��4��                    2��2���#�ǣ����~�������������������                            	��@��������������������� ���                                	������E��o�ܜ��������         �   �                          �  �   �   �   �   v       �� ���     0            00   h        �      (   00    �         �       h         �        h     �      �� ���     0	        �Ȁ         �     S e l e c t   D e v i c e    M S   S h e l l   D l g       P      � - ����� R e n d e r i n g   d e v i c e        P      A 
 ����� & A d a p t e r :      !P    Z  i d ����        P       A 
 ����� & D e v i c e :        !P    Z  i d ����         P     4 � - ����� R e n d e r i n g   m o d e       	 P    
 > U  ���� U s e   d e s k t o p   & w i n d o w     	  P    
 M K  ���� & F u l l s c r e e n   m o d e :      #P    Z M i � ����         P     e �  ����� M u l t i s a m p l e      P     q > 
 ����� & M u l t i s a m p l e   T y p e :        !P    Z o i d ����        P    � 
 2   ��� O K         P    �  2   ��� C a n c e l       �      �� ��     	        (       @         �                        �  �   �� �   � � ��  ��� ���   �  �   �� �   � � ��  ���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ��������������������������������������������������������������������������������������������������������������������������������(      �� ��     	        (                �                         �  �   �� �   � � ��  ��� ���   �  �   �� �   � � ��  ��� ���xf������DG���d�DDD��fffff��vfffffg�vfffffh�vfh�fff��f�xff�g����f������fo�����vg�������g�������v��������w���������������                                                                �      �� ��     	        (       @                                �  �   �� �   � � ��  ��� ��� �ʦ       """ ))) UUU MMM BBB 999 �|� PP� � � ��� ��� ��� ���   3   f   �   �  3   33  3f  3�  3�  3�  f   f3  ff  f�  f�  f�  �   �3  �f  ��  ��  ��  �   �3  �f  ̙  ��  ��  �f  ��  �� 3   3 3 3 f 3 � 3 � 3 � 33  333 33f 33� 33� 33� 3f  3f3 3ff 3f� 3f� 3f� 3�  3�3 3�f 3�� 3�� 3�� 3�  3�3 3�f 3̙ 3�� 3�� 3�3 3�f 3�� 3�� 3�� f   f 3 f f f � f � f � f3  f33 f3f f3� f3� f3� ff  ff3 fff ff� ff� f�  f�3 f�f f�� f�� f�� f�  f�3 f̙ f�� f�� f�  f�3 f�� f�� � � � � ��  �3� � � � � �   �33 � f �3� � � �f  �f3 �3f �f� �f� �3� ��3 ��f ��� ��� ��� ��  ��3 f�f �̙ ��� ��� ��  ��3 ��f ��� ��� ��� �   � 3 � f � � � � �3  �33 �3f �3� �3� �3� �f  �f3 �ff �f� �f� �f� ̙  ̙3 ̙f ̙� ̙� ̙� ��  ��3 ��f �̙ ��� ��� ��  ��3 ��f ��� ��� ��� � 3 � f � � �3  �33 �3f �3� �3� �3� �f  �f3 �ff �f� �f� �f� ��  ��3 ��f ��� ��� ��� ��  ��3 ��f �̙ ��� ��� ��3 ��f ��� ��� ff� f�f f�� �ff �f� ��f ! � ___ www ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���   �  �   �� �   � � ��  ��� 







                        






                         




                           



                            



                            


                             

                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                      

















          












����������������������?�� �� �� ����?���������������������������?����������������������������������������������h      �� ��     	        (                @                        �  �   �� �   � � ��  ��� ��� �ʦ       """ ))) UUU MMM BBB 999 �|� PP� � � ��� ��� ��� ���   3   f   �   �  3   33  3f  3�  3�  3�  f   f3  ff  f�  f�  f�  �   �3  �f  ��  ��  ��  �   �3  �f  ̙  ��  ��  �f  ��  �� 3   3 3 3 f 3 � 3 � 3 � 33  333 33f 33� 33� 33� 3f  3f3 3ff 3f� 3f� 3f� 3�  3�3 3�f 3�� 3�� 3�� 3�  3�3 3�f 3̙ 3�� 3�� 3�3 3�f 3�� 3�� 3�� f   f 3 f f f � f � f � f3  f33 f3f f3� f3� f3� ff  ff3 fff ff� ff� f�  f�3 f�f f�� f�� f�� f�  f�3 f̙ f�� f�� f�  f�3 f�� f�� � � � � ��  �3� � � � � �   �33 � f �3� � � �f  �f3 �3f �f� �f� �3� ��3 ��f ��� ��� ��� ��  ��3 f�f �̙ ��� ��� ��  ��3 ��f ��� ��� ��� �   � 3 � f � � � � �3  �33 �3f �3� �3� �3� �f  �f3 �ff �f� �f� �f� ̙  ̙3 ̙f ̙� ̙� ̙� ��  ��3 ��f �̙ ��� ��� ��  ��3 ��f ��� ��� ��� � 3 � f � � �3  �33 �3f �3� �3� �3� �f  �f3 �ff �f� �f� �f� ��  ��3 ��f ��� ��� ��� ��  ��3 ��f �̙ ��� ��� ��3 ��f ��� ��� ff� f�f f�� �ff �f� ��f ! � ___ www ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ���   �  �   �� �   � � ��  ��� 


























����






feeeBBD�



eBBCBDn�


`Bm��Lnl�

g##J������s�


��f=f��ڳfD






hb>f�h��








��bb�gB








�����ek�








���ڊ����







g��Բ�*h








��ۭ�Mm









�ڭ



































��  ��  �   �  �        �  �  �  �  �  �  ��  ��  ��  >       �� ��e     0	                 �      (         �       h            ��	 ��q     0 	          C�  � X F�  f       �� ��     0          	 1 2 7 . 0 . 0 . 1  1  0  1  1  2 0 0 7 0 7 1 2  5 4 0 0  5 0 0 0  5  1 2 5 2  0           