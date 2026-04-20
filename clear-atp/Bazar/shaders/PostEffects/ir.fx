#include "common/Samplers11.hlsl"
#include "common/States11.hlsl"
#include "clear_flir_config.hlsl"

// =============================================================================
// clear-flir ir.fx - upstream RGB->IR conversion + box blur + gain + level
// stage that runs before AdjustFLIR.fx. All tunable values live in
// clear_flir_config.hlsl next to this file - edit ONE file and both this
// shader and AdjustFLIR.fx pick up the change.
// =============================================================================

float4 params;
Texture2D source;
float4	viewport;

struct VS_OUTPUT {
	float4 pos:			SV_POSITION0;
	float2 texCoord:	TEXCOORD0;
};

static const float2 quad[4] = {
	float2(-1, -1),
	float2( 1, -1),
	float2(-1,  1),
	float2( 1,  1),
};


VS_OUTPUT VS(uint vid: SV_VertexID) {
	VS_OUTPUT o;
	float2 p = quad[vid];
	o.pos = float4(p, 0, 1);
	o.texCoord = float2(p.x*0.5 + 0.5, -p.y*0.5 + 0.5)*viewport.zw + viewport.xy;
	return o;
}

float getIR(float2 tex_coord) {
	float4 InColor = source.Sample(WrapPointSampler, tex_coord);
	float amp = 0.35 * pow(abs((1.0 - 0.33*(InColor.r + 0.9*InColor.g - InColor.b))), 7.2);
	return pow(2.8 *(1 - cos(3.14 * amp)), 0.7);
}

float calcResult(float2 tex_coord) {
	float Color = 0;
	float blur_factor = params[0] * (1.0 + FOCUS_AMPLIFICATION * params[3]);

	for (float i = -BLUR_RADIUS; i <= BLUR_RADIUS; i++) {
		for (float j = -BLUR_RADIUS; j <= BLUR_RADIUS; j++)
			Color += SAMPLE_WEIGHT * getIR(tex_coord + blur_factor*float2(i, j));
	}

	// gain control
	Color = (Color - 0.5)*pow(16.0, params[1]) + 0.5;

	// level control
	Color += params[2];

	return Color;
}

float4 PS_WH(VS_OUTPUT i): SV_TARGET0 {
	float c = calcResult(i.texCoord);
	return float4(c, c, c, 1);
}

float4 PS_BH(VS_OUTPUT i): SV_TARGET0{
	float c = 1.0-calcResult(i.texCoord);
	return float4(c, c, c, 1);
}

technique10 WhiteHot {
	pass P0
	{
		SetVertexShader(CompileShader(vs_4_0, VS()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_4_0, PS_WH()));

		SetDepthStencilState(disableDepthBuffer, 0);
		SetBlendState(disableAlphaBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
		SetRasterizerState(cullNone);
	}
}

technique10 BlackHot {
	pass P0
	{
		SetVertexShader(CompileShader(vs_4_0, VS()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_4_0, PS_BH()));

		SetDepthStencilState(disableDepthBuffer, 0);
		SetBlendState(disableAlphaBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
		SetRasterizerState(cullNone);
	}
}
